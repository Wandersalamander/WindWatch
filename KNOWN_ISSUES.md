# Known issues

Taken over from TwelveLakes and not yet checked on LakeWind.

## Glance shows no wind at first on older watches

On the fr55, instinct2 and descentg1 the TwelveLakes glance received and
stored its value, but the watch did not redraw the glance after
`requestUpdate()`. The wind should show the next time the glance is drawn.

## Not checked on touch watches

`scripts/simulator_screenshots.py` presses keys but cannot swipe, so the lake
list was not seen on the venu, vivoactive and approach watches. On the venusq2
the menu did not open either.

## Wind on small lakes

Open-Meteo picks the weather model cell of the lake's position. On small lakes
in narrow valleys the model wind can differ from the wind on the water, and
local winds like the Bise or thermal winds are smoothed out.
