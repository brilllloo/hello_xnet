class FileWriter:
    def __init__(self, path):
        self.path = path
    
    def write(self, msg):
        f = open(self.path, "w")
        f.write(msg + "test")
        f.close()

