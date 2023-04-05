#!/bin/bash
set -x
git clone https://github.com/hwchiu/2023-course.git

cd 2023-course
./env.sh install
./env.sh create
./env.sh verify
