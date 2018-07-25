import time
import zmq

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("tcp://*:5555")

while True:
    msg = input("Please enter something: ")
    #  Send reply back to client
    socket.send_string(msg)
