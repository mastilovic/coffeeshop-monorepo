/** Official cities and towns in Serbia (Latin script). Keep in sync with backend reference/serbia-cities.json */
export const SERBIA_CITIES = [
  'Aleksinac',
  'Apatin',
  'Aranđelovac',
  'Bačka Palanka',
  'Bečej',
  'Beograd',
  'Bor',
  'Čačak',
  'Dimitrovgrad',
  'Inđija',
  'Jagodina',
  'Kanjiža',
  'Kikinda',
  'Kraljevo',
  'Kragujevac',
  'Kruševac',
  'Kula',
  'Leskovac',
  'Loznica',
  'Negotin',
  'Niš',
  'Novi Pazar',
  'Novi Sad',
  'Pančevo',
  'Paraćin',
  'Pirot',
  'Požarevac',
  'Priboj',
  'Prijepolje',
  'Prokuplje',
  'Ruma',
  'Senta',
  'Sjenica',
  'Smederevo',
  'Sombor',
  'Sremska Mitrovica',
  'Subotica',
  'Surdulica',
  'Šabac',
  'Svilajnac',
  'Tutin',
  'Užice',
  'Valjevo',
  'Vlasotince',
  'Vranje',
  'Vrbas',
  'Vršac',
  'Zaječar',
  'Zrenjanin',
  'Ćuprija',
] as const;

/** Keep mapping in sync with backend SearchTextNormalizer */
export function normalizeCityForSearch(value: string): string {
  return value
    .replace(/đ/g, 'dj')
    .replace(/Đ/g, 'dj')
    .replace(/č/g, 'c')
    .replace(/Č/g, 'c')
    .replace(/ć/g, 'c')
    .replace(/Ć/g, 'c')
    .replace(/š/g, 's')
    .replace(/Š/g, 's')
    .replace(/ž/g, 'z')
    .replace(/Ž/g, 'z')
    .toLowerCase()
    .normalize('NFD')
    .replace(/\p{M}/gu, '');
}

export function filterSerbiaCities(query: string): string[] {
  if (!query.trim()) {
    return [...SERBIA_CITIES];
  }
  const normalizedQuery = normalizeCityForSearch(query);
  return SERBIA_CITIES.filter(city =>
    normalizeCityForSearch(city).includes(normalizedQuery),
  );
}

export function isSerbiaCity(value: string): boolean {
  const trimmed = value.trim();
  return (SERBIA_CITIES as readonly string[]).includes(trimmed);
}
