import { css } from "@emotion/react";
import ClipLoader from "react-spinners/ClipLoader";
import React from "react";

// Can be a string as well. Need to ensure each key-value pair ends with ;
const override = css`
position: fixed;
top: 50%;
left: 50%;
margin-top: -50px;
margin-left: -100px;
`;

exports.mkSpinner = () => {
  return <ClipLoader color={"#ffffff"} css={override} size={150} />
}