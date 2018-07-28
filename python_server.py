import time
import zmq

context = zmq.Context()
socket = context.socket(zmq.DEALER)
socket.bind("tcp://*:5555")

while True:
    msg = input("Please enter something: ")
    #  Send reply back to client
    socket.send_string(msg)
    # socket.send(b"WORLD\r\n")
    message = socket.recv()
    print("Received message: %s" % message)
