#!/bin/sh
valac -C -H webkit6go.h --pkg gtk4 --pkg webkitgtk-6.0 --pkg libnotify --pkg posix ../webkit6.vala

mv webkit* ../../..
