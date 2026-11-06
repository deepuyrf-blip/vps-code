// ---------------------------------------------------------------- straw-boats cast v3
// Matching the reference sheets: pure white faces, big round heads, thick ink
// outline, no beards on the hero, simple bean bodies, flat colours.

OUTFITS.liang = {
  tunic: '#7fa8cc', skin: '#FFFFFF', hair: '#1e1714',
};
OUTFITS.drummer = {
  tunic: '#b23a2e', skin: '#FFFFFF', hair: '#1e1714', bare: true,
};
OUTFITS.general = {
  tunic: '#8a3b30', cape: '#6b2a24', skin: '#FFFFFF', armor: true, helmet: true,
  stout: true,
};
OUTFITS.archer = {
  tunic: '#3f5a72', skin: '#FFFFFF', helmet: true,
};
OUTFITS.archerOfficer = {
  tunic: '#4d4a5e', skin: '#FFFFFF', helmet: true, cape: '#3a3547',
};

// A straw dummy that reads as a sack with a painted face — white like the rest
// of the cast, cream sack, thick ink outline, one crooked helmet, one stick spear.
export const strawFront = (p, opts = {}) => {
  const { helmet = true, stick = true, seed = 1, ow = 14 } = opts;
  const wob = (i) => Math.sin(seed * 2.1 + i) * 7;
  const SACK = '#EFE3C4', STRAW = '#E8D9A8', ROPE = '#B08A4A', INK = '#1e1714';

  p.poly([
    [300 + wob(0) - 92, 975], [300 + wob(1) - 110, 800], [300 + wob(2) - 96, 640],
    [300 + wob(3) - 62, 520], [300 + wob(4) + 62, 520], [300 + wob(5) + 96, 640],
    [300 + wob(6) + 110, 800], [300 + wob(7) + 92, 975],
  ], SACK, ow);

  p.stroke([[196, 700], [404, 696]], 9, ROPE);
  p.stroke([[208, 622], [392, 618]], 9, ROPE);

  for (let i = 0; i < 6; i++) {
    const x = 244 + i * 22;
    p.stroke([[x, 522], [x + Math.sin(i) * 12, 492 + Math.cos(i) * 6]], 6, STRAW);
  }
  for (let i = 0; i < 8; i++) {
    const x = 224 + i * 19;
    p.stroke([[x, 972], [x + Math.sin(i * 2) * 10, 996]], 5, STRAW);
  }

  p.ell(300, 585, 64, 52, '#FFFFFF', 10);
  p.ell(276, 578, 8, 8, INK, 0);
  p.ell(324, 578, 8, 8, INK, 0);
  p.stroke([[282, 610], [318, 610]], 5, INK);

  p.rot = [0.12, 300, 470];
  p.ell(300, 452, 92, 50, '#B9C2CA', ow);
  p.poly([[212, 452], [388, 452], [366, 426], [234, 426]], '#CFD6DC', 12);
  p.stroke([[300, 402], [300, 376]], 7, '#8E979E');
  p.rot = null;

  if (stick) {
    p.stroke([[388, 940], [414, 300]], 10, '#9C7A4A');
    p.poly([[414, 300], [426, 250], [402, 250]], '#B9C2CA', 6);
  }
  return p;
};

export const drumFront = (p) => {
  p.ell(300, 500, 120, 140, '#A8542E', 14);
  p.ell(300, 500, 102, 122, '#F3E2C4', 10);
  p.stroke([[300, 380], [300, 620]], 6, '#A8542E');
  p.dot(300, 500, 9);
  return p;
};

export const fanFront = (p) => {
  for (let i = -3; i <= 3; i++) {
    p.poly([[300, 620], [300 + i * 44 - 16, 300 + Math.abs(i) * 12],
            [300 + i * 44 + 16, 300 + Math.abs(i) * 12]], '#FBF7EE', 8);
  }
  p.ell(300, 300, 160, 36, '#FBF7EE', 10);
  p.stroke([[300, 620], [300, 760]], 12, '#8A6A3C');
  return p;
};
