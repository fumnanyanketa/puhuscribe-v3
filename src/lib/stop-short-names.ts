// Short names for the stop signs on the road (fast route road-signs, owner approved 5 November 2026).
// A sign on the road shows the short name. Screen-reader labels, the stop screen, the cards and
// everything else keep the full stop name from the database.

export const STOP_SHORT_NAMES: Readonly<Record<number, string>> = {
  1: 'Meeting people',
  2: 'Café',
  3: 'Groceries',
  4: 'Paying',
  5: 'Bus and tram',
  6: 'Small talk',
  7: 'Asking for help',
  8: 'Making plans',
  9: 'Appointments',
  10: 'Pharmacy',
  11: 'Neighbours',
  12: 'Clothes',
  13: 'Health centre',
  14: 'Phone calls',
  15: 'Bank and Kela',
  16: 'Parcels',
  17: 'Lunch out',
  18: 'Housing',
  19: 'New job',
  20: 'Family',
  21: 'School',
  22: 'Hobbies',
  23: 'Cooking',
  24: 'Feelings',
  25: 'Coffee and sauna',
  26: 'Holidays',
  27: 'Seasons',
  28: 'Library',
  29: 'Nature',
  30: 'Celebrations',
  31: 'Directions',
  32: 'Returns',
  33: 'My past',
  34: 'My plans',
  35: 'My skills',
  36: 'My day',
}

/** The name a road sign shows: the short name, or the full name for a stop with no short one. */
export function stopShortName(stop: number, fullName: string): string {
  return STOP_SHORT_NAMES[stop] ?? fullName
}
