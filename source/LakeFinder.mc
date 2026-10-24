import Toybox.Position;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
using Toybox.WatchUi;

(:glance)
function readableLakeName(lake as String?) as String {
    // generated code because monkey c does not allow getting the resource by string..
    if (lake == null) {
        return "No lake";
    }
    switch (lake) {
        case "ageri":
            return WatchUi.loadResource(Rez.Strings.ageri) as String;
        case "baldegg":
            return WatchUi.loadResource(Rez.Strings.baldegg) as String;
        case "hallwil":
            return WatchUi.loadResource(Rez.Strings.hallwil) as String;
        case "biel":
            return WatchUi.loadResource(Rez.Strings.biel) as String;
        case "upperconstance":
            return WatchUi.loadResource(Rez.Strings.upperconstance) as String;
        case "lowerconstance":
            return WatchUi.loadResource(Rez.Strings.lowerconstance) as String;
        case "brienz":
            return WatchUi.loadResource(Rez.Strings.brienz) as String;
        case "thun":
            return WatchUi.loadResource(Rez.Strings.thun) as String;
        case "geneva":
            return WatchUi.loadResource(Rez.Strings.geneva) as String;
        case "greifensee":
            return WatchUi.loadResource(Rez.Strings.greifensee) as String;
        case "gruyere":
            return WatchUi.loadResource(Rez.Strings.gruyere) as String;
        case "klontalersee":
            return WatchUi.loadResource(Rez.Strings.klontalersee) as String;
        case "joux":
            return WatchUi.loadResource(Rez.Strings.joux) as String;
        case "maggiore":
            return WatchUi.loadResource(Rez.Strings.maggiore) as String;
        case "zurich":
            return WatchUi.loadResource(Rez.Strings.zurich) as String;
        case "lucernekreuztrichterandvitznauerbecken":
            return (
                WatchUi.loadResource(
                    Rez.Strings.lucernekreuztrichterandvitznauerbecken
                ) as String
            );
        case "lucerneurnersee":
            return WatchUi.loadResource(Rez.Strings.lucerneurnersee) as String;
        case "lucernegersauerandtreibbecken":
            return (
                WatchUi.loadResource(
                    Rez.Strings.lucernegersauerandtreibbecken
                ) as String
            );
        case "lungern":
            return WatchUi.loadResource(Rez.Strings.lungern) as String;
        case "murten":
            return WatchUi.loadResource(Rez.Strings.murten) as String;
        case "neuchatel":
            return WatchUi.loadResource(Rez.Strings.neuchatel) as String;
        case "pfaffikon":
            return WatchUi.loadResource(Rez.Strings.pfaffikon) as String;
        case "sempach":
            return WatchUi.loadResource(Rez.Strings.sempach) as String;
        case "sarnen":
            return WatchUi.loadResource(Rez.Strings.sarnen) as String;
        case "lucernealpnachersee":
            return WatchUi.loadResource(Rez.Strings.alpnachersee) as String;
        case "lugano":
            return WatchUi.loadResource(Rez.Strings.lugano) as String;
        case "walensee":
            return WatchUi.loadResource(Rez.Strings.walensee) as String;
        case "zug":
            return WatchUi.loadResource(Rez.Strings.zug) as String;
        case "sihlsee":
            return WatchUi.loadResource(Rez.Strings.sihlsee) as String;
        case "poschiavo":
            return WatchUi.loadResource(Rez.Strings.poschiavo) as String;
        case "sils":
            return WatchUi.loadResource(Rez.Strings.sils) as String;
        case "silvaplana":
            return WatchUi.loadResource(Rez.Strings.silvaplana) as String;
        case "stmoritz":
            return WatchUi.loadResource(Rez.Strings.stmoritz) as String;
        case "champfer":
            return WatchUi.loadResource(Rez.Strings.champfer) as String;
        case "lauerz":
            return WatchUi.loadResource(Rez.Strings.lauerz) as String;
        case "rotsee":
            return WatchUi.loadResource(Rez.Strings.rotsee) as String;
        case "turlersee":
            return WatchUi.loadResource(Rez.Strings.turlersee) as String;
        case "amsoldingersee":
            return WatchUi.loadResource(Rez.Strings.amsoldingersee) as String;
        case "moossee":
            return WatchUi.loadResource(Rez.Strings.moossee) as String;
        case "mauensee":
            return WatchUi.loadResource(Rez.Strings.mauensee) as String;
        case "oeschinensee":
            return WatchUi.loadResource(Rez.Strings.oeschinensee) as String;
        case "soppensee":
            return WatchUi.loadResource(Rez.Strings.soppensee) as String;
        case "inkwilersee":
            return WatchUi.loadResource(Rez.Strings.inkwilersee) as String;
        case "huttwilersee":
            return WatchUi.loadResource(Rez.Strings.huttwilersee) as String;
        case "cadagno":
            return WatchUi.loadResource(Rez.Strings.cadagno) as String;
        case "husemersee":
            return WatchUi.loadResource(Rez.Strings.husemersee) as String;
        case "huttnersee":
            return WatchUi.loadResource(Rez.Strings.huttnersee) as String;
        case "lutzelsee":
            return WatchUi.loadResource(Rez.Strings.lutzelsee) as String;
        case "mettmenhaslisee":
            return WatchUi.loadResource(Rez.Strings.mettmenhaslisee) as String;
        case "egelsee":
            return WatchUi.loadResource(Rez.Strings.egelsee) as String;
        case "untererchatzensee":
            return (
                WatchUi.loadResource(Rez.Strings.untererchatzensee) as String
            );
        case "seeweidsee":
            return WatchUi.loadResource(Rez.Strings.seeweidsee) as String;
        case "burgaschisee":
            return WatchUi.loadResource(Rez.Strings.burgaschisee) as String;
        case "burgseeli":
            return WatchUi.loadResource(Rez.Strings.burgseeli) as String;
        case "dittligsee":
            return WatchUi.loadResource(Rez.Strings.dittligsee) as String;
        case "gerzensee":
            return WatchUi.loadResource(Rez.Strings.gerzensee) as String;
        case "lobsigensee":
            return WatchUi.loadResource(Rez.Strings.lobsigensee) as String;
        case "chlimoossee":
            return WatchUi.loadResource(Rez.Strings.chlimoossee) as String;
        case "uebeschisee":
            return WatchUi.loadResource(Rez.Strings.uebeschisee) as String;
        case "bret":
            return WatchUi.loadResource(Rez.Strings.bret) as String;
        case "brenet":
            return WatchUi.loadResource(Rez.Strings.brenet) as String;
        case "chavonnes":
            return WatchUi.loadResource(Rez.Strings.chavonnes) as String;
        case "bretaye":
            return WatchUi.loadResource(Rez.Strings.bretaye) as String;
        case "lioson":
            return WatchUi.loadResource(Rez.Strings.lioson) as String;
        case "tome":
            return WatchUi.loadResource(Rez.Strings.tome) as String;
        case "barone":
            return WatchUi.loadResource(Rez.Strings.barone) as String;
        case "superiore":
            return WatchUi.loadResource(Rez.Strings.superiore) as String;
        case "sassolo":
            return WatchUi.loadResource(Rez.Strings.sassolo) as String;
        case "geistsee":
            return WatchUi.loadResource(Rez.Strings.geistsee) as String;
        case "lenkerseeli":
            return WatchUi.loadResource(Rez.Strings.lenkerseeli) as String;
        case "stockseewli":
            return WatchUi.loadResource(Rez.Strings.stockseewli) as String;
        case "oberesbanzlauiseeli":
            return (
                WatchUi.loadResource(Rez.Strings.oberesbanzlauiseeli) as String
            );
        case "barchetsee":
            return WatchUi.loadResource(Rez.Strings.barchetsee) as String;
        case "bichelsee":
            return WatchUi.loadResource(Rez.Strings.bichelsee) as String;
        case "hasenseeost":
            return WatchUi.loadResource(Rez.Strings.hasenseeost) as String;
        case "hasenseewest":
            return WatchUi.loadResource(Rez.Strings.hasenseewest) as String;
        case "hauptwilerweiher":
            return WatchUi.loadResource(Rez.Strings.hauptwilerweiher) as String;
        case "hugiweiher":
            return WatchUi.loadResource(Rez.Strings.hugiweiher) as String;
        case "obererbommerweiher":
            return (
                WatchUi.loadResource(Rez.Strings.obererbommerweiher) as String
            );
        case "marwilermoos":
            return WatchUi.loadResource(Rez.Strings.marwilermoos) as String;
        case "nussbommersee":
            return WatchUi.loadResource(Rez.Strings.nussbommersee) as String;
        case "vagoweiher":
            return WatchUi.loadResource(Rez.Strings.vagoweiher) as String;
        case "wilemersee":
            return WatchUi.loadResource(Rez.Strings.wilemersee) as String;
        case "wistererweiher":
            return WatchUi.loadResource(Rez.Strings.wistererweiher) as String;
        case "garda":
            return WatchUi.loadResource(Rez.Strings.garda) as String;
        case "caldonazzo":
            return WatchUi.loadResource(Rez.Strings.caldonazzo) as String;
    }
    return "No lake";
}

// Larger than any distance in degrees on earth
const UNREACHABLE_DISTANCE = 1000.0d;
// Length of a degree of latitude
const METERS_PER_DEGREE = 111195.0d;

// Lake borders are loaded from resources one lake at a time, because all of
// them at once take about 22kB, too much for 64kB widgets. Each lake has a
// circle around its border points, so lakes are visited nearest circle first
// until no remaining lake can be closer than the closest border point found.
// See scripts/generate_lake_resources.py
function getClosesLake(position_lat_long as [Double, Double]?) as String? {
    var lake = closestLake(position_lat_long);
    if (lake == null) {
        return null;
    }
    return lake[0];
}

//! [name, distance in meters] of the lake with the closest border point
function closestLake(
    position_lat_long as [Double, Double]?
) as [String, Float]? {
    System.println("closestLake");
    if (position_lat_long == null) {
        return null;
    }
    var longitudeScale = longitudeScaleAt(position_lat_long[0]);
    var lowerBounds = distancesToLakeCircles(
        position_lat_long,
        longitudeScale,
        WatchUi.loadResource(Rez.JsonData.LakeCircles) as Array<Float>
    );
    var borderResources = lakeBorderResources();
    var closestDistance = UNREACHABLE_DISTANCE;
    var closestLakeName = null;
    for (var visited = 0; visited < lowerBounds.size(); visited++) {
        var lake = indexOfMinimum(lowerBounds);
        if (lowerBounds[lake] > closestDistance) {
            break;
        }
        lowerBounds[lake] = UNREACHABLE_DISTANCE;
        var border = WatchUi.loadResource(borderResources[lake]) as Dictionary;
        var distance = distanceToBorder(
            position_lat_long,
            longitudeScale,
            border["points"] as Array<[Float, Float]>
        );
        if (distance < closestDistance) {
            closestDistance = distance;
            closestLakeName = border["name"] as String;
        }
    }
    if (closestLakeName == null) {
        return null;
    }
    return [closestLakeName, (closestDistance * METERS_PER_DEGREE).toFloat()];
}

//! Lower bound of the distance to each lake, from circles given
//! as latitude, longitude and radius per lake. The radii are in unscaled
//! degrees, which are never shorter than scaled ones, so they stay lower bounds.
function distancesToLakeCircles(
    position_lat_long as [Double, Double],
    longitudeScale as Double,
    circles as Array<Float>
) as Array<Double> {
    var lakeCount = circles.size() / 3;
    var distances = new Array<Double>[lakeCount];
    for (var i = 0; i < lakeCount; i++) {
        var center = [circles[3 * i], circles[3 * i + 1]];
        distances[i] =
            degreeDistance(position_lat_long, center, longitudeScale) -
            circles[3 * i + 2];
    }
    return distances;
}

function distanceToBorder(
    position_lat_long as [Double, Double],
    longitudeScale as Double,
    border as Array<[Float, Float]>
) as Double {
    var closestDistance = UNREACHABLE_DISTANCE;
    for (var i = 0; i < border.size(); i++) {
        var distance = degreeDistance(
            position_lat_long,
            border[i],
            longitudeScale
        );
        if (distance < closestDistance) {
            closestDistance = distance;
        }
    }
    return closestDistance;
}

//! Length of a degree of longitude in degrees of latitude, which is the
//! same for all lakes because they are close to each other
function longitudeScaleAt(latitude as Double) as Double {
    return Math.cos(Math.toRadians(latitude)).toDouble();
}

//! Distance in degrees of latitude, with longitudes scaled by longitudeScale
function degreeDistance(
    position_lat_long as [Double, Double],
    lakePos as [Float, Float],
    longitudeScale as Double
) as Double {
    var dx = lakePos[0] - position_lat_long[0];
    var dy = (lakePos[1] - position_lat_long[1]) * longitudeScale;
    return Math.sqrt(dx * dx + dy * dy).toDouble();
}

function indexOfMinimum(values as Array<Double>) as Number {
    var minimumIndex = 0;
    for (var i = 1; i < values.size(); i++) {
        if (values[i] < values[minimumIndex]) {
            minimumIndex = i;
        }
    }
    return minimumIndex;
}

function getLakeByGPS() as String? {
    System.println("getLakeByGPS");
    var position_lat_long = getPosition();
    return getClosesLake(position_lat_long);
}

function getPosition() as [Double, Double]? {
    System.println("getPosition");
    var info = Position.getInfo();

    // if (info != null){
    System.println(info.accuracy);
    System.println(Position.QUALITY_LAST_KNOWN);
    if (info.accuracy >= Position.QUALITY_LAST_KNOWN) {
        var position = info.position;
        if (position != null) {
            System.println(position.toDegrees());
            return position.toDegrees();
        }
    }
    return null;
}
