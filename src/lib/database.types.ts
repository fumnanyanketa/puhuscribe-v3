
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export type Database = {
  
  "public": {
          Tables: {
            "cards": {
                  Row: {
                    "created_at": string,"difficulty": number,"due": string,"elapsed_days": number,"form_id": number,"lapses": number,"last_review": string | null,"reps": number,"scheduled_days": number,"stability": number,"state": Database["public"]['Enums']["card_state"],"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"difficulty"?: number,"due"?: string,"elapsed_days"?: number,"form_id": number,"lapses"?: number,"last_review"?: string | null,"reps"?: number,"scheduled_days"?: number,"stability"?: number,"state"?: Database["public"]['Enums']["card_state"],"user_id"?: string
                  }
                  Update: {
                    "created_at"?: string,"difficulty"?: number,"due"?: string,"elapsed_days"?: number,"form_id"?: number,"lapses"?: number,"last_review"?: string | null,"reps"?: number,"scheduled_days"?: number,"stability"?: number,"state"?: Database["public"]['Enums']["card_state"],"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "cards_form_id_fkey"
      columns: ["form_id"]
isOneToOne: false
      referencedRelation: "forms"
      referencedColumns: ["id"]
    }
                  ]
                },"consents": {
                  Row: {
                    "created_at": string,"granted": boolean,"id": string,"kind": Database["public"]['Enums']["consent_kind"],"notice_version": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"granted": boolean,"id"?: string,"kind": Database["public"]['Enums']["consent_kind"],"notice_version": string,"user_id"?: string
                  }
                  Update: {
                    "created_at"?: string,"granted"?: boolean,"id"?: string,"kind"?: Database["public"]['Enums']["consent_kind"],"notice_version"?: string,"user_id"?: string
                  }
                  Relationships: [
                    
                  ]
                },"dialogue_lines": {
                  Row: {
                    "approval_ref": string | null,"approved_at": string | null,"audio_kirja_key": string | null,"audio_puhe_key": string | null,"dialogue_id": number,"gloss_en": string | null,"id": number,"position": number,"speaker": string,"status": Database["public"]['Enums']["content_status"],"text_kirja": string | null,"text_puhe": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "approval_ref"?: string | null,"approved_at"?: string | null,"audio_kirja_key"?: string | null,"audio_puhe_key"?: string | null,"dialogue_id": number,"gloss_en"?: string | null,"id"?: never,"position": number,"speaker": string,"status"?: Database["public"]['Enums']["content_status"],"text_kirja"?: string | null,"text_puhe"?: string | null
                  }
                  Update: {
                    "approval_ref"?: string | null,"approved_at"?: string | null,"audio_kirja_key"?: string | null,"audio_puhe_key"?: string | null,"dialogue_id"?: number,"gloss_en"?: string | null,"id"?: never,"position"?: number,"speaker"?: string,"status"?: Database["public"]['Enums']["content_status"],"text_kirja"?: string | null,"text_puhe"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "dialogue_lines_dialogue_id_fkey"
      columns: ["dialogue_id"]
isOneToOne: false
      referencedRelation: "dialogues"
      referencedColumns: ["id"]
    }
                  ]
                },"dialogues": {
                  Row: {
                    "approval_ref": string | null,"approved_at": string | null,"id": number,"position": number,"slug": string,"status": Database["public"]['Enums']["content_status"],"title_en": string,"unit_id": number
                  }
                  ComputedFields: never
                  Insert: {
                    "approval_ref"?: string | null,"approved_at"?: string | null,"id"?: never,"position": number,"slug": string,"status"?: Database["public"]['Enums']["content_status"],"title_en": string,"unit_id": number
                  }
                  Update: {
                    "approval_ref"?: string | null,"approved_at"?: string | null,"id"?: never,"position"?: number,"slug"?: string,"status"?: Database["public"]['Enums']["content_status"],"title_en"?: string,"unit_id"?: number
                  }
                  Relationships: [
                    {
      foreignKeyName: "dialogues_unit_id_fkey"
      columns: ["unit_id"]
isOneToOne: false
      referencedRelation: "units"
      referencedColumns: ["id"]
    }
                  ]
                },"forms": {
                  Row: {
                    "analysis": Json | null,"approval_ref": string | null,"approved_at": string | null,"form_name_en": string | null,"form_tag": string,"id": number,"lemma": string,"status": Database["public"]['Enums']["content_status"],"surface_kirja": string,"surface_puhe": string,"why_en": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "analysis"?: Json | null,"approval_ref"?: string | null,"approved_at"?: string | null,"form_name_en"?: string | null,"form_tag": string,"id"?: never,"lemma": string,"status"?: Database["public"]['Enums']["content_status"],"surface_kirja": string,"surface_puhe": string,"why_en"?: string | null
                  }
                  Update: {
                    "analysis"?: Json | null,"approval_ref"?: string | null,"approved_at"?: string | null,"form_name_en"?: string | null,"form_tag"?: string,"id"?: never,"lemma"?: string,"status"?: Database["public"]['Enums']["content_status"],"surface_kirja"?: string,"surface_puhe"?: string,"why_en"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"kept_recordings": {
                  Row: {
                    "audio": string,"created_at": string,"id": string,"line_id": number,"slot": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "audio": string,"created_at"?: string,"id"?: string,"line_id": number,"slot": string,"user_id"?: string
                  }
                  Update: {
                    "audio"?: string,"created_at"?: string,"id"?: string,"line_id"?: number,"slot"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "kept_recordings_line_id_fkey"
      columns: ["line_id"]
isOneToOne: false
      referencedRelation: "dialogue_lines"
      referencedColumns: ["id"]
    }
                  ]
                },"lemma_ipa": {
                  Row: {
                    "ipa": string,"lemma": string,"licence": string,"source": string
                  }
                  ComputedFields: never
                  Insert: {
                    "ipa": string,"lemma": string,"licence": string,"source": string
                  }
                  Update: {
                    "ipa"?: string,"lemma"?: string,"licence"?: string,"source"?: string
                  }
                  Relationships: [
                    
                  ]
                },"review_logs": {
                  Row: {
                    "difficulty": number,"due": string,"elapsed_days": number,"form_id": number,"id": string,"last_elapsed_days": number,"mode": Database["public"]['Enums']["review_mode"],"rating": number,"review_time": string,"scheduled_days": number,"stability": number,"state": Database["public"]['Enums']["card_state"],"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "difficulty": number,"due": string,"elapsed_days": number,"form_id": number,"id"?: string,"last_elapsed_days": number,"mode": Database["public"]['Enums']["review_mode"],"rating": number,"review_time": string,"scheduled_days": number,"stability": number,"state": Database["public"]['Enums']["card_state"],"user_id"?: string
                  }
                  Update: {
                    "difficulty"?: number,"due"?: string,"elapsed_days"?: number,"form_id"?: number,"id"?: string,"last_elapsed_days"?: number,"mode"?: Database["public"]['Enums']["review_mode"],"rating"?: number,"review_time"?: string,"scheduled_days"?: number,"stability"?: number,"state"?: Database["public"]['Enums']["card_state"],"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "review_logs_form_id_fkey"
      columns: ["form_id"]
isOneToOne: false
      referencedRelation: "forms"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "review_logs_user_id_form_id_fkey"
      columns: ["user_id","form_id"]
isOneToOne: false
      referencedRelation: "cards"
      referencedColumns: ["user_id","form_id"]
    }
                  ]
                },"sessions": {
                  Row: {
                    "dialogue_id": number | null,"ended_at": string | null,"id": string,"started_at": string,"step_reached": Database["public"]['Enums']["loop_step"] | null,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "dialogue_id"?: number | null,"ended_at"?: string | null,"id"?: string,"started_at"?: string,"step_reached"?: Database["public"]['Enums']["loop_step"] | null,"user_id"?: string
                  }
                  Update: {
                    "dialogue_id"?: number | null,"ended_at"?: string | null,"id"?: string,"started_at"?: string,"step_reached"?: Database["public"]['Enums']["loop_step"] | null,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "sessions_dialogue_id_fkey"
      columns: ["dialogue_id"]
isOneToOne: false
      referencedRelation: "dialogues"
      referencedColumns: ["id"]
    }
                  ]
                },"source_sentences": {
                  Row: {
                    "gloss_en": string,"id": number,"note": string,"source": string,"source_ref": string,"text_kirja": string,"text_puhe": string
                  }
                  ComputedFields: never
                  Insert: {
                    "gloss_en": string,"id"?: never,"note": string,"source": string,"source_ref": string,"text_kirja": string,"text_puhe": string
                  }
                  Update: {
                    "gloss_en"?: string,"id"?: never,"note"?: string,"source"?: string,"source_ref"?: string,"text_kirja"?: string,"text_puhe"?: string
                  }
                  Relationships: [
                    
                  ]
                },"speaking_attempts": {
                  Row: {
                    "audio_ms": number,"cost_usd": number,"created_at": string,"feedback_class": Database["public"]['Enums']["speech_feedback_class"],"form_id": number | null,"id": string,"line_id": number | null,"provider": string,"session_id": string | null,"transcript": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "audio_ms": number,"cost_usd": number,"created_at"?: string,"feedback_class": Database["public"]['Enums']["speech_feedback_class"],"form_id"?: number | null,"id"?: string,"line_id"?: number | null,"provider": string,"session_id"?: string | null,"transcript"?: string,"user_id"?: string
                  }
                  Update: {
                    "audio_ms"?: number,"cost_usd"?: number,"created_at"?: string,"feedback_class"?: Database["public"]['Enums']["speech_feedback_class"],"form_id"?: number | null,"id"?: string,"line_id"?: number | null,"provider"?: string,"session_id"?: string | null,"transcript"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "speaking_attempts_form_id_fkey"
      columns: ["form_id"]
isOneToOne: false
      referencedRelation: "forms"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "speaking_attempts_line_id_fkey"
      columns: ["line_id"]
isOneToOne: false
      referencedRelation: "dialogue_lines"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "speaking_attempts_session_id_fkey"
      columns: ["session_id"]
isOneToOne: false
      referencedRelation: "sessions"
      referencedColumns: ["id"]
    }
                  ]
                },"speech_checks": {
                  Row: {
                    "created_at": string,"id": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"id"?: string,"user_id"?: string
                  }
                  Update: {
                    "created_at"?: string,"id"?: string,"user_id"?: string
                  }
                  Relationships: [
                    
                  ]
                },"tokens": {
                  Row: {
                    "form_id": number | null,"id": number,"line_id": number,"position": number,"register": Database["public"]['Enums']["finnish_register"],"surface": string
                  }
                  ComputedFields: never
                  Insert: {
                    "form_id"?: number | null,"id"?: never,"line_id": number,"position": number,"register": Database["public"]['Enums']["finnish_register"],"surface": string
                  }
                  Update: {
                    "form_id"?: number | null,"id"?: never,"line_id"?: number,"position"?: number,"register"?: Database["public"]['Enums']["finnish_register"],"surface"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "tokens_form_id_fkey"
      columns: ["form_id"]
isOneToOne: false
      referencedRelation: "forms"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "tokens_line_id_fkey"
      columns: ["line_id"]
isOneToOne: false
      referencedRelation: "dialogue_lines"
      referencedColumns: ["id"]
    }
                  ]
                },"units": {
                  Row: {
                    "approval_ref": string | null,"approved_at": string | null,"can_do_en": string,"id": number,"position": number,"slug": string,"status": Database["public"]['Enums']["content_status"],"title_en": string
                  }
                  ComputedFields: never
                  Insert: {
                    "approval_ref"?: string | null,"approved_at"?: string | null,"can_do_en": string,"id"?: never,"position": number,"slug": string,"status"?: Database["public"]['Enums']["content_status"],"title_en": string
                  }
                  Update: {
                    "approval_ref"?: string | null,"approved_at"?: string | null,"can_do_en"?: string,"id"?: never,"position"?: number,"slug"?: string,"status"?: Database["public"]['Enums']["content_status"],"title_en"?: string
                  }
                  Relationships: [
                    
                  ]
                },"usage_events": {
                  Row: {
                    "created_at": string,"id": string,"name": Database["public"]['Enums']["usage_event_name"],"session_id": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"id"?: string,"name": Database["public"]['Enums']["usage_event_name"],"session_id": string,"user_id"?: string
                  }
                  Update: {
                    "created_at"?: string,"id"?: string,"name"?: Database["public"]['Enums']["usage_event_name"],"session_id"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "usage_events_session_id_fkey"
      columns: ["session_id"]
isOneToOne: false
      referencedRelation: "sessions"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "complete_session":
{ Args: { "session_id": string }; Returns: undefined
                           },
"keep_recording":
{ Args: { "audio_base64": string,"line_id": number }; Returns: string
                           },
"next_review_day":
{ Args: Record<PropertyKey, never>; Returns: {
              "next_day": string,"today": string
            }[]
                           },
"record_review":
{ Args: { "p_difficulty": number,"p_due": string,"p_elapsed_days": number,"p_expected_reps": number,"p_form_id": number,"p_lapses": number,"p_last_review": string,"p_log_difficulty": number,"p_log_due": string,"p_log_elapsed_days": number,"p_log_last_elapsed_days": number,"p_log_scheduled_days": number,"p_log_stability": number,"p_log_state": Database["public"]['Enums']["card_state"],"p_mode": Database["public"]['Enums']["review_mode"],"p_rating": number,"p_reps": number,"p_review_time": string,"p_scheduled_days": number,"p_stability": number,"p_state": Database["public"]['Enums']["card_state"] }; Returns: boolean
                           },
"reserve_speech_check":
{ Args: { "max_checks": number,"window_minutes": number }; Returns: boolean
                           },
"review_queue":
{ Args: { "p_limit": number }; Returns: {
              "due": string,"form_id": number,"reps": number
            }[]
                           }
          }
          Enums: {
            "card_state": "new"|"learning"|"review"|"relearning","consent_kind": "voice_processing"|"voice_recording_retention","content_status": "draft"|"approved"|"retired","finnish_register": "puhe"|"kirja","loop_step": "hear"|"understand"|"say"|"keep"|"use","review_mode": "typed"|"spoken","speech_feedback_class": "clear"|"close"|"try_again"|"not_heard","usage_event_name": "first_session_completed"
          }
          CompositeTypes: {
            [_ in never]: never
          }
        }
}

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
  ? (DefaultSchema["Tables"] & DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
      Row: infer R
    }
    ? R
    : never
  : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Insert: infer I
    }
    ? I
    : never
  : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Update: infer U
    }
    ? U
    : never
  : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
  ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
  : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never
> = PublicCompositeTypeNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
  ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never

export const Constants = {
  "public": {
          Enums: {
            "card_state": ["new", "learning", "review", "relearning"],"consent_kind": ["voice_processing", "voice_recording_retention"],"content_status": ["draft", "approved", "retired"],"finnish_register": ["puhe", "kirja"],"loop_step": ["hear", "understand", "say", "keep", "use"],"review_mode": ["typed", "spoken"],"speech_feedback_class": ["clear", "close", "try_again", "not_heard"],"usage_event_name": ["first_session_completed"]
          }
        }
} as const
