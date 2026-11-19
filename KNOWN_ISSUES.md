# Known issues

Taken over from TwelveLakes and not yet checked on WindWatch.

## Glance shows no wind at first on older watches

On the fr55, instinct2 and descentg1 the TwelveLakes glance received and
stored its value, but the watch did not redraw the glance after
`requestUpdate()`. The wind should show the next time the glance is drawn.

## Swipe hint over the page title on touch watches

On the venu, venusq2 and vivoactive the page loop shows a swipe up hint at
the bottom of the screen, which covers half of the page title. In the
simulator it stays there; check on a real watch whether it hides.

## Watch hands over the chart on the Instinct Crossover

The hands of the Instinct Crossover park across the middle of the screen
while the app shows, where they hide the gust marks and the top of the
bars, and the first menu item.

## Model wind on small lakes

Open-Meteo picks the weather model cell of the position. On small lakes in
narrow valleys the model wind can differ from the wind on the water, and
local winds like the Bise or thermal winds are smoothed out.

## Glance in GPS mode

Glances get no GPS, so in GPS mode the glance shows the wind at the last
position the view got, until the view is opened again.

## Forecast pages not checked on watches without the page loop

Watches on Connect IQ 3, like the fenix 6, MARQ, fr55, fr745, fr945,
Instinct 2 and Descent MK2, run the app as a widget, where the watch's own
page loop fails to start. They switch the forecast pages in one view
instead. In the simulator the fenix 6, fr55 and fr745 show the view and the
menu, but DOWN moves the widget carousel on, as the simulator starts the
widget in the carousel, so switching pages there was not seen. Check it on
a real watch, opened from the glance.
