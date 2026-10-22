// The unit's "can do" statement, with a plain label so the learner knows why
// it is there (design review, job 8 round 1). The same wording on the front
// door and on Hear it.

export const CAN_DO_LABEL = 'Unit goal.'

export function CanDo({ text, className }: { text: string; className?: string }) {
  return (
    <p className={className}>
      <strong>{CAN_DO_LABEL}</strong> {text}
    </p>
  )
}
