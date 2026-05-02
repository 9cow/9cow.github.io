export const getRandomBytes = (n) => {
  const bytes = new Uint8Array(n);
  crypto.getRandomValues(bytes);
  return bytes;
};

export const bytesToHex = (bytes) => {
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
};

export const hexToBytes = (hexString) => {
  if (hexString.length % 2 !== 0) {
    throw new Error("Invalid hex string length");
  }
  const bytes = new Uint8Array(hexString.length / 2);
  for (let i = 0; i < hexString.length; i += 2) {
    bytes[i / 2] = parseInt(hexString.substr(i, 2), 16);
  }
  return bytes;
};

export const andBytes = (bytes1, bytes2) => {
  const length = Math.min(bytes1.length, bytes2.length);
  const result = new Uint8Array(length);
  for (let i = 0; i < length; i++) {
    result[i] = bytes1[i] & bytes2[i];
  }
  return result;
};

export const orBytes = (bytes1, bytes2) => {
  const length = Math.min(bytes1.length, bytes2.length);
  const result = new Uint8Array(length);
  for (let i = 0; i < length; i++) {
    result[i] = bytes1[i] | bytes2[i];
  }
  return result;
};
