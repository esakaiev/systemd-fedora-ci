#!/usr/bin/python
import sys
import logging
logging.basicConfig(level=logging.INFO)

instance = sys.argv[1]

data = sys.stdin.readline().strip()
logging.info('test-service: at instance %s, got request: %s', instance, data)
sys.stdout.write(data + '\r\n')
