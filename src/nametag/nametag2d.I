// Filename: nametag2d.I
// Created by:  drose (19Jul01)
//
////////////////////////////////////////////////////////////////////

INLINE void Nametag2d::ref() const {
  ReferenceCount::ref();
}

INLINE bool Nametag2d::unref() const {
  return ReferenceCount::unref();
}
