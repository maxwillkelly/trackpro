#!bin/bash
# Allows the user to access a repository by changing into it

cd $1
ls -R $1
exec $SHELL