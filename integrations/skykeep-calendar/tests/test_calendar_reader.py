import importlib.util,sqlite3,tempfile,unittest,datetime as dt
from pathlib import Path
from zoneinfo import ZoneInfo
spec=importlib.util.spec_from_file_location('reader',Path(__file__).parents[1]/'contents/code/calendar_reader.py')
reader=importlib.util.module_from_spec(spec);spec.loader.exec_module(reader)
class CalendarReaderTest(unittest.TestCase):
 def test_floating_all_day_disabled_and_multiday(self):
  with tempfile.TemporaryDirectory() as directory:
   db=Path(directory)/'library.db'
   with sqlite3.connect(db) as c:
    c.executescript('CREATE TABLE calendars(guid TEXT,title TEXT,enabled INTEGER); CREATE TABLE events(title TEXT,location TEXT,starts_at INTEGER,ends_at INTEGER,all_day INTEGER,floating INTEGER,calendar_guid TEXT); CREATE TABLE sync_state(service TEXT,last_synced_at INTEGER); INSERT INTO calendars VALUES("a","Test",1),("b","Disabled",0);')
    def stamp(s):return int(dt.datetime.fromisoformat(s).replace(tzinfo=dt.timezone.utc).timestamp())
    c.executemany('INSERT INTO events VALUES(?,?,?,?,?,?,?)',[
      ('floating','',stamp('2026-11-06T14:00'),stamp('2026-11-06T15:00'),0,1,'a'),
      ('day','',stamp('2026-11-06T00:00'),stamp('2026-11-07T00:00'),1,1,'a'),
      ('hidden','',stamp('2026-11-06T14:00'),stamp('2026-11-06T15:00'),0,1,'b')])
   before=db.read_bytes()
   result=reader.read(db,now=dt.datetime(2026,11,6,12,tzinfo=ZoneInfo('Europe/Rome')))
   day=next(d for d in result['days'] if d['date']=='2026-11-06')
   self.assertEqual(day['count'],2)
   self.assertEqual(next(e for e in day['events'] if e['title']=='floating')['time'],'14:00 – 15:00')
   self.assertEqual(next(d for d in result['days'] if d['date']=='2026-11-07')['count'],0)
   self.assertEqual(before,db.read_bytes())
   self.assertEqual(len(result['days']),42)
if __name__=='__main__':unittest.main()
