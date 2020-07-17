import tornado.ioloop
import tornado.web
from datetime import datetime
import time
import math
import pickle

# pull: connection ready, start pulling
# ok: not pull new, uses local
# pullok: pull new done
class DroneStatus:
    def __init__(self, _id):
        self.id = _id
        self.last_update = time.time()
        self.status = "NULL"

    def set_pulling(self):
        self.status = "PULLING"

    def set_pulling_OK(self):
        self.status = "OK"
        self.last_update =time.time()

    def set_uptodate(self):
        self.status = "OK"
        self.last_update = time.time()

    def print_info(self):
        return "Node {} Status {} Last Update: {:4.1f}s ago".format(
            self.id, self.status,
            time.time() - self.last_update
        )

class SwarmFirmwareDatabase:
    def __init__(self):
        self.drones = {} # [DroneStatus(i) for i in range(10)]
        self.last_push_id = -1
        self.last_image = ""
        self.last_pushtime = -1

    def check_drone_exist(self, drone_id):
        if not (drone_id in self.drones):
            self.drones[drone_id] = DroneStatus(drone_id)

    def set_pull_id(self, drone_id):
        self.check_drone_exist(drone_id)
        print("Node {} pulling".format(drone_id))
        self.drones[drone_id].set_pulling()
        dump_db(self)

    def set_ok_id(self, drone_id):
        self.check_drone_exist(drone_id)
        print("Node {} up-to-date".format(drone_id))
        self.drones[drone_id].set_uptodate()
        dump_db(self)

    def set_pull_ok(self, drone_id):
        self.check_drone_exist(drone_id)
        print("Node {} pull OK".format(drone_id))
        self.drones[drone_id].set_pulling_OK()
        dump_db(self)

    def get_drones(self):
        return self.drones

    def time_now(self):
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def push_ago(self):
        return math.floor(time.time() - self.last_pushtime)

    def print_info(self, _id):
        return self.drones[_id].print_info() + " Is lastest:{}".format( self.drones[_id].last_update > self.last_pushtime)

    def push(self, id, image):
        self.last_push_id = id
        self.last_image = image
        self.last_pushtime = time.time()
        self.set_ok_id(id)
        dump_db(self)

class PullHandler(tornado.web.RequestHandler):
    def initialize(self, db):
        self.db = db
    def get(self, _id):
        self.write("OK")
        print("Node {} pulling image".format(_id))
        self.db.set_pull_id(_id)

class OKHandler(tornado.web.RequestHandler):
    def initialize(self, db):
        self.db = db
    def get(self, _id):
        self.write("OK")
        print("Node {} up-to-date".format(_id))
        self.db.set_ok_id(_id)

class PullOKHandler(tornado.web.RequestHandler):
    def initialize(self, db):
        self.db = db
    def get(self, _id):
        self.write("OK")
        print("Node {} pull image OK".format(_id))
        self.db.set_pull_ok(_id)

class PushHandler(tornado.web.RequestHandler):
    def initialize(self, db):
        self.db = db
    def get(self, _id, image):
        self.db.push(_id, image)
        self.write("{} PUSH IMAGE {}".format(_id, image))

class MainHandler(tornado.web.RequestHandler):
    def initialize(self, db):
        self.db = db

    def get(self):
        self.render("template.html", title="Drone Firmware", db=self.db)

DB_PATH = "/home/xuhao/mf2/fw.db"
def dump_db(db):
    global DB_PATH
    print("Update DB", DB_PATH)
    pickle.dump(db, open(DB_PATH, "wb"))

def main():
    try:
        db = pickle.load(open(DB_PATH, "rb"))
        print("Successful load db from file")
    except:
        print("Local db failed, will create")
        db = SwarmFirmwareDatabase()
        dump_db(db)

    port = 8888
    app = tornado.web.Application([
    (r"/pull/([0-9]+)", PullHandler, dict(db=db)),
    (r"/pull_ok/([0-9]+)", PullOKHandler, dict(db=db)),
    (r"/ok/([0-9]+)", OKHandler, dict(db=db)),
    (r"/push/([0-9]+)/(.*)", PushHandler, dict(db=db)),
    (r"/", MainHandler, dict(db=db))
    ])

    print("server inited; waiting for connection on port", port)
    app.listen(port)
    tornado.ioloop.IOLoop.current().start()

main()
