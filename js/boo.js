export const getRandomBytes = (n) => {
  const bytes = new Uint8Array(n);
  crypto.getRandomValues(bytes);
  return bytes;
};
