#!/bin/bash
sleep 600
if ps aux | grep -v grep | grep iguana >/dev/null                                                                     
then                                                                                                                  
    exit 0                                                              
else
    /home/eclips/tools/otary    
fi
