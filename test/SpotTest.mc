import Toybox.Lang;
import Toybox.Test;

(:test)
function positionKeyRoundsToAboutAKilometre(logger as Logger) as Boolean {
    return positionKey([46.288474d, 6.174525d]).equals(
        "latitude=46.29&longitude=6.17"
    );
}

(:test)
function positionKeyKeepsTheSign(logger as Logger) as Boolean {
    return positionKey([-33.8568d, -9.4211d]).equals(
        "latitude=-33.86&longitude=-9.42"
    );
}
