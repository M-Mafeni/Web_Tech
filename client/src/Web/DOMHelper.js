"use strict";

exports.setInnerHTML = function (element) {
  return function (innerHtml) {
    return function () {
      element.innerHTML = innerHtml;
    };
  };
};