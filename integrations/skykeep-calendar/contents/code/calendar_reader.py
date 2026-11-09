#!/usr/bin/env python3
"""Read Skykeep's already-expanded event cache. No credentials, network or writes."""
import argparse, calendar, datetime as dt, json, sqlite3
from pathlib import Path
from zoneinfo import ZoneInfo

WEEKDAYS = ['lunedì','martedì','mercoledì','giovedì','venerdì','sabato','domenica']
MONTHS = ['gennaio','febbraio','marzo','aprile','maggio','giugno','luglio','agosto','settembre','ottobre','novembre','dicembre']

def read(database, offset=0, now=None):
    with open('/etc/localtime', 'rb') as f:
        zone = ZoneInfo.from_file(f)
    now = now or dt.datetime.now(zone)
    n = now.year * 12 + now.month - 1 + offset
    year, month = n // 12, n % 12 + 1
    first = dt.date(year, month, 1)
    start = first - dt.timedelta(days=first.weekday())
    stop = start + dt.timedelta(days=42)
    lower = int(dt.datetime.combine(start, dt.time(), zone).timestamp())
    upper = int(dt.datetime.combine(stop, dt.time(), zone).timestamp())
    days = [{'date':(start+dt.timedelta(days=i)).isoformat(), 'number':(start+dt.timedelta(days=i)).day,
             'currentMonth':(start+dt.timedelta(days=i)).month == month, 'events':[], 'count':0} for i in range(42)]
    for day in days:
        date = dt.date.fromisoformat(day['date'])
        day['label'] = f'{WEEKDAYS[date.weekday()]} {date.day} {MONTHS[date.month-1]}'
    with sqlite3.connect(database.resolve().as_uri()+'?mode=ro', uri=True, timeout=.25) as c:
        c.execute('PRAGMA query_only=ON')
        c.row_factory = sqlite3.Row
        rows = c.execute('''SELECT e.title,e.location,e.starts_at,e.ends_at,e.all_day,e.floating,c.title calendar
            FROM events e JOIN calendars c ON c.guid=e.calendar_guid WHERE c.enabled=1
            AND e.starts_at < ? AND e.ends_at > ? ORDER BY e.starts_at,e.title LIMIT 2000''', (upper+86400,lower-86400))
        def instant(value, floating):
            if floating:
                return dt.datetime.fromtimestamp(value, dt.timezone.utc).replace(tzinfo=zone)
            return dt.datetime.fromtimestamp(value, zone)
        for row in rows:
            a,b = instant(row['starts_at'],row['floating']),instant(row['ends_at'],row['floating'])
            for day in days:
                date = dt.date.fromisoformat(day['date'])
                begin = dt.datetime.combine(date,dt.time(),zone)
                end = dt.datetime.combine(date+dt.timedelta(days=1),dt.time(),zone)
                if a >= end or b <= begin:
                    continue
                day['count'] += 1
                if len(day['events']) < 16:
                    day['events'].append({'title':row['title'],'location':row['location'] or '',
                       'calendar':row['calendar'], 'allDay':bool(row['all_day']),
                       'time':'TUTTO IL GIORNO' if row['all_day'] else a.strftime('%H:%M')+' – '+b.strftime('%H:%M'),
                       'past':b <= now})
        stamp = c.execute("SELECT last_synced_at FROM sync_state WHERE service='calendar'").fetchone()
    return {'month':MONTHS[month-1]+' '+str(year),'today':now.date().isoformat(),'first':first.isoformat(),
            'days':days,'synced':dt.datetime.fromtimestamp(stamp[0],zone).strftime('%d/%m %H:%M') if stamp and stamp[0] else 'non ancora sincronizzato'}

def main():
    p=argparse.ArgumentParser(); p.add_argument('--month-offset',type=int,default=0); p.add_argument('--database',type=Path)
    args=p.parse_args()
    try:
        if not -120 <= args.month_offset <= 120: raise ValueError('Limite navigazione: dieci anni.')
        choices=[Path.home()/'.var/app/io.github.yashwanthkamireddi.Skykeep/data/io.github.yashwanthkamireddi.Skykeep/library.db',
                 Path.home()/'.local/share/io.github.yashwanthkamireddi.Skykeep/library.db']
        database=args.database or next((x for x in choices if x.is_file()),None)
        if database is None: raise ValueError('Apri Skykeep e sincronizza il calendario.')
        print(json.dumps(read(database,args.month_offset),ensure_ascii=False))
    except (OSError,ValueError,sqlite3.Error) as e:
        print(json.dumps({'error':'Calendario non disponibile: '+str(e)},ensure_ascii=False))
if __name__=='__main__': main()
