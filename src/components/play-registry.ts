// Only one play control sounds at a time (design.md, "Play control"). A
// control registers a stop function when it starts; starting another calls
// the previous one first.

let stopCurrent: (() => void) | null = null

export function startExclusive(stop: () => void): void {
  if (stopCurrent && stopCurrent !== stop) stopCurrent()
  stopCurrent = stop
}

export function finished(stop: () => void): void {
  if (stopCurrent === stop) stopCurrent = null
}
