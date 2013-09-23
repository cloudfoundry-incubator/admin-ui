#!/bin/sh

echo "Creating new DEA..."

for count in 1 2 3 4 5
do
  sleep 1
  echo "... $count"
done

sleep 2
echo "encountered an error" >&2
sleep 2

for count in 1 2 3 4 5
do
  sleep .25
  echo "... $count"
done

sleep 2
echo "encountered another error" >&2
sleep 2

for count in 1 2 3 4 5
do
  sleep .01
  echo "... $count"
done

sleep 2
echo "encountered final error" >&2
sleep 2

for count in 1 2 3 4 5
do
  echo "... $count"
done

sleep 4
echo "Finished creating new DEA."
