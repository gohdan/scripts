#!/bin/bash

find $1 -printf "%T@ %Tc %p\n" | sort -rn 
