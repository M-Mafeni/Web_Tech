"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.mkSpinner = mkSpinner;

var _ClipLoader = _interopRequireDefault(require("react-spinners/ClipLoader"));

var _react = _interopRequireDefault(require("react"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function mkSpinner() {
  return /*#__PURE__*/_react["default"].createElement(_ClipLoader["default"], {
    color: "#ffffff",
    size: 150
  });
}