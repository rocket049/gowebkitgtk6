project('webkit6go','c')
gtkdep = dependency('gtk4')
webkitdep = dependency('webkitgtk-6.0')
src = ['webkit6.c', 'webkit6_bridge.c']
static_library('webkit6go', src, dependencies : [gtkdep, webkitdep])
