import * as boo from './js/boo.js';

const boton = document.getElementById('btn-generar');
const display = document.getElementById('resultado');

const manejarClick = () => {
  const bytes = boo.getRandomBytes(16);
  const hex = boo.bytesToHex(bytes);

  display.textContent = `Generado: ${hex}`;
};

boton.addEventListener('click', manejarClick);
