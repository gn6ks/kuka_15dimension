function ih = inverse(h)

t = GetTranslation(h);
r = GetRotation(h);
ih.m = [r' -r'*t; zeros(1,3) 1];
ih = class(ih,'ht');
