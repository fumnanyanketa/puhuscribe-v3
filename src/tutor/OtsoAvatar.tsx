import { useState } from 'react'
import styles from './Tutor.module.css'

// Otso's face (owner's change, 3 November 2026): a small round portrait beside his name, as in a chat
// app. The owner supplies the picture later as one file, public/otso/avatar.webp. Until it is there,
// or when it cannot load, a plain mint round with the letter O stands in. The picture shows a person
// who does not exist, made by AI; the note next to Otso's name says he is an AI.

/** The one place the picture is read from. */
export const OTSO_AVATAR_PATH = '/otso/avatar.webp'
export const OTSO_AVATAR_ALT = 'Otso, your AI tutor'

export function OtsoAvatar() {
  const [failed, setFailed] = useState(false)
  if (failed) {
    return (
      <span className={styles.avatarFallback} role="img" aria-label={OTSO_AVATAR_ALT}>
        <span aria-hidden="true">O</span>
      </span>
    )
  }
  return (
    <img
      className={styles.avatar}
      src={OTSO_AVATAR_PATH}
      alt={OTSO_AVATAR_ALT}
      width={36}
      height={36}
      decoding="async"
      onError={() => {
        setFailed(true)
      }}
    />
  )
}

/** Otso's name with his face and the quiet "AI" note, above his first line and on the guest card. */
export function OtsoName({ face = false, as: Tag = 'p' }: { face?: boolean; as?: 'p' | 'h2' }) {
  return (
    <Tag className={styles.name}>
      {face && <OtsoAvatar />}
      <span className={styles.nameText}>Otso</span>
      <span className={styles.aiNote}>AI</span>
    </Tag>
  )
}
