import Toybox.Communications;
import Toybox.Lang;

//! Gets the answer of a PositionRequest with the position key it was for
typedef AnswerHandler as (Method
    (
        responseCode as Number,
        data as Dictionary or String or Null,
        key as String
    ) as Void
);

//! A web request for the data of a position key, which keeps the key itself:
//! watches do not hand the :context option of makeWebRequest back when they
//! fail a request at once, and call back with two arguments only.
(:glance)
class PositionRequest {
    private var _key as String;
    // The caller does not keep its requests, so they form no reference cycle
    private var _onAnswer as AnswerHandler;

    function initialize(key as String, onAnswer as AnswerHandler) {
        _key = key;
        _onAnswer = onAnswer;
    }

    function start(url as String) as Void {
        Communications.makeWebRequest(
            url,
            null,
            {
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            },
            method(:onReceive)
        );
    }

    //! Each value has one stored slot, so an answer that comes in after the
    //! shown position changed would replace the data of the shown one
    function onReceive(
        responseCode as Number,
        data as Dictionary or String or Null
    ) as Void {
        if (positionKey(shownPosition()).equals(_key)) {
            _onAnswer.invoke(responseCode, data, _key);
        }
    }
}
