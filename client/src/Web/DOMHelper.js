exports.setInnerHTML = (element) => (innerHtml) => () => {
  element.innerHTML = innerHtml
}