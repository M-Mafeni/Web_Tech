"use strict";

var _react = require("@emotion/react");

var _ClipLoader = _interopRequireDefault(require("react-spinners/ClipLoader"));

var _react2 = _interopRequireDefault(require("react"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _EMOTION_STRINGIFIED_CSS_ERROR__() { return "You have tried to stringify object returned from `css` function. It isn't supposed to be used directly (e.g. as value of the `className` prop), but rather handed to emotion so it can handle it (e.g. as value of `css` prop)."; }

// Can be a string as well. Need to ensure each key-value pair ends with ;
var override = process.env.NODE_ENV === "production" ? {
  name: "16exnsf",
  styles: "position:fixed;top:50%;left:50%;margin-top:-50px;margin-left:-100px"
} : {
  name: "1hqc3mb-override",
  styles: "position:fixed;top:50%;left:50%;margin-top:-50px;margin-left:-100px;label:override;",
  map: "/*# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIlNwaW5uZXIuanN4Il0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUtvQiIsImZpbGUiOiJTcGlubmVyLmpzeCIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IGNzcyB9IGZyb20gXCJAZW1vdGlvbi9yZWFjdFwiO1xyXG5pbXBvcnQgQ2xpcExvYWRlciBmcm9tIFwicmVhY3Qtc3Bpbm5lcnMvQ2xpcExvYWRlclwiO1xyXG5pbXBvcnQgUmVhY3QgZnJvbSBcInJlYWN0XCI7XHJcblxyXG4vLyBDYW4gYmUgYSBzdHJpbmcgYXMgd2VsbC4gTmVlZCB0byBlbnN1cmUgZWFjaCBrZXktdmFsdWUgcGFpciBlbmRzIHdpdGggO1xyXG5jb25zdCBvdmVycmlkZSA9IGNzc2BcclxucG9zaXRpb246IGZpeGVkO1xyXG50b3A6IDUwJTtcclxubGVmdDogNTAlO1xyXG5tYXJnaW4tdG9wOiAtNTBweDtcclxubWFyZ2luLWxlZnQ6IC0xMDBweDtcclxuYDtcclxuXHJcbmV4cG9ydHMubWtTcGlubmVyID0gKCkgPT4ge1xyXG4gIHJldHVybiA8Q2xpcExvYWRlciBjb2xvcj17XCIjZmZmZmZmXCJ9IGNzcz17b3ZlcnJpZGV9IHNpemU9ezE1MH0gLz5cclxufSJdfQ== */",
  toString: _EMOTION_STRINGIFIED_CSS_ERROR__
};

exports.mkSpinner = function () {
  return /*#__PURE__*/_react2["default"].createElement(_ClipLoader["default"], {
    color: "#ffffff",
    css: override,
    size: 150
  });
};