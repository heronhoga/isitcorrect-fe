<script setup lang="ts">
import { ref, watch, onUnmounted } from "vue";
import { checkGrammarAPI } from "./api/grammar";

const text = ref("");
const isCharLimitExceeded = ref(false);
const isLoading = ref(false);
const showModal = ref(false);
const isError = ref(false);
const errorMessage = ref("");

// Recording state
const isRecording = ref(false);
const recordingError = ref("");
const recordingPulse = ref(false);
let recognition: any = null;

interface Issue {
  original: string;
  fix: string;
  reason: string;
}

interface GrammarResult {
  corrected: string;
  issues: Issue[];
}

const result = ref<GrammarResult | null>(null);

watch(text, (newValue) => {
  if (newValue.length > 512) {
    text.value = newValue.slice(0, 512);
  }
  isCharLimitExceeded.value = newValue.length >= 512;
});

function startRecording() {
  recordingError.value = "";

  const SpeechRecognition =
    (window as any).SpeechRecognition ||
    (window as any).webkitSpeechRecognition;

  if (!SpeechRecognition) {
    recordingError.value =
      "Speech recognition is not supported in this browser.";
    return;
  }

  recognition = new SpeechRecognition();
  recognition.lang = "en-US";
  recognition.interimResults = false;
  recognition.maxAlternatives = 1;
  recognition.continuous = false;

  recognition.onstart = () => {
    isRecording.value = true;
    recordingPulse.value = true;
  };

  recognition.onresult = (event: any) => {
    const transcript = event.results[0][0].transcript;
    const remaining = 512 - text.value.length;
    if (remaining > 0) {
      const toAppend = text.value
        ? " " + transcript.slice(0, remaining - 1)
        : transcript.slice(0, remaining);
      text.value += toAppend;
    }
  };

  recognition.onerror = (event: any) => {
    if (event.error !== "aborted") {
      recordingError.value = `Recording failed: ${event.error}`;
    }
    isRecording.value = false;
    recordingPulse.value = false;
  };

  recognition.onend = () => {
    isRecording.value = false;
    recordingPulse.value = false;
  };

  recognition.start();
}

function stopRecording() {
  if (recognition) {
    recognition.stop();
  }
}

function toggleRecording() {
  if (isRecording.value) {
    stopRecording();
  } else {
    startRecording();
  }
}

onUnmounted(() => {
  if (recognition) recognition.abort();
});

function clearText() {
  text.value = "";
  isCharLimitExceeded.value = false;
  recordingError.value = "";
  isError.value = false;
  errorMessage.value = "";
}

async function checkGrammar() {
  if (!text.value.trim()) return;

  isLoading.value = true;
  showModal.value = false;
  result.value = null;
  isError.value = false;
  errorMessage.value = "";

  try {
    const response = await checkGrammarAPI(text.value);

    if (!response || response.error) {
      isError.value = true;
      errorMessage.value = response?.error || "An unknown error occurred.";
      return;
    }

    result.value = response;
    showModal.value = true;
  } catch (err: any) {
    isError.value = true;
    errorMessage.value = err.message || "Request failed";
  } finally {
    isLoading.value = false;
  }
}

function closeModal() {
  showModal.value = false;
}
</script>

<template>
  <div class="nb-root">
    <div class="nb-card">
      <h1 class="nb-title">Is It <span>Correct?</span></h1>
      <p class="nb-desc">
        Simple grammar corrector — in case you need help with your writing in an
        immediate way.
        <span class="nb-badge">by Hoga</span>
      </p>

      <label class="nb-label" for="grammar-input">Your text</label>
      <div class="nb-input-container">
        <p class="nb-label">total: {{ text.length }}/512 characters</p>
        <p v-if="isCharLimitExceeded" class="nb-error">
          You have exceeded the character limit.
        </p>
      </div>
      <textarea
        v-model="text"
        id="grammar-input"
        class="nb-textarea"
        rows="10"
        maxlength="512"
        placeholder="Type your text here.. or hit REC to speak it (limited compatibility on some browsers)."
        :disabled="isLoading"
      ></textarea>

      <!-- Recording error -->
      <p v-if="recordingError" class="nb-error nb-error--recording">
        ⚠ {{ recordingError }}
      </p>

      <p v-if="isError" class="nb-error">
        An error occurred while checking grammar: {{ errorMessage }}
      </p>

      <div class="nb-btn-container">
        <!-- Record button -->
        <button
          class="nb-btn nb-btn--record"
          :class="{ 'nb-btn--recording': isRecording }"
          type="button"
          :disabled="isLoading"
          @click="toggleRecording"
          :aria-label="isRecording ? 'Stop recording' : 'Start recording'"
        >
          <span
            class="nb-rec-dot"
            :class="{ 'nb-rec-dot--active': isRecording }"
          ></span>
          <span>{{ isRecording ? "Stop" : "Rec" }}</span>
        </button>

        <!-- Check grammar button -->
        <button
          class="nb-btn"
          type="button"
          :disabled="isLoading || !text.trim() || isRecording"
          @click="checkGrammar"
        >
          <span v-if="isLoading" class="nb-btn-loading">
            <span class="nb-spinner"></span> Checking...
          </span>
          <span v-else>✦ Check Grammar</span>
        </button>

        <button class="nb-btn-clear" type="button" @click="clearText">
          <span>Clear Text</span>
        </button>
      </div>

      <!-- Recording live indicator -->
      <Transition name="fade">
        <div v-if="isRecording" class="nb-recording-banner">
          <div class="nb-recording-bars">
            <span></span><span></span><span></span><span></span><span></span>
          </div>
          <span class="nb-recording-label">Listening... speak now</span>
          <div class="nb-recording-bars nb-recording-bars--mirror">
            <span></span><span></span><span></span><span></span><span></span>
          </div>
        </div>
      </Transition>

      <p class="nb-footer">
        no data stored. instagram
        <a
          class="nb-footer-insta"
          href="https://instagram.com/1afrinata"
          target="_blank"
          >@1afrinata</a
        >
      </p>
    </div>

    <!-- Loading Overlay -->
    <Transition name="fade">
      <div v-if="isLoading" class="nb-overlay">
        <div class="nb-overlay-inner">
          <div class="nb-loading-box">
            <div class="nb-loading-bars">
              <span></span><span></span><span></span><span></span>
            </div>
            <p class="nb-loading-text">Analyzing your text...</p>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Results Modal -->
    <Transition name="modal">
      <div
        v-if="showModal && result"
        class="nb-overlay"
        @click.self="closeModal"
      >
        <div class="nb-modal">
          <div class="nb-modal-header">
            <h2 class="nb-modal-title">Grammar <span>Report</span></h2>
            <button class="nb-close-btn" @click="closeModal" aria-label="Close">
              ✕
            </button>
          </div>

          <div class="nb-issues-meta">
            <span
              class="nb-issues-badge"
              :class="result.issues.length === 0 ? 'nb-issues-badge--none' : ''"
            >
              {{
                result.issues.length === 0
                  ? "✓ No issues found"
                  : `${result.issues.length} issue${result.issues.length > 1 ? "s" : ""} found`
              }}
            </span>
          </div>

          <div class="nb-section">
            <p class="nb-section-label">✦ Corrected Text</p>
            <div class="nb-corrected-box">{{ result.corrected }}</div>
          </div>

          <div v-if="result.issues.length > 0" class="nb-section">
            <p class="nb-section-label">✦ Issues Breakdown</p>
            <div class="nb-issues-list">
              <div
                v-for="(issue, index) in result.issues"
                :key="index"
                class="nb-issue-card"
              >
                <div class="nb-issue-index">
                  {{ String(index + 1).padStart(2, "0") }}
                </div>
                <div class="nb-issue-body">
                  <div class="nb-issue-row">
                    <span class="nb-issue-pill nb-issue-pill--original"
                      >Before</span
                    >
                    <span class="nb-issue-text nb-issue-text--original">{{
                      issue.original
                    }}</span>
                  </div>
                  <div class="nb-issue-row">
                    <span class="nb-issue-pill nb-issue-pill--fix">After</span>
                    <span class="nb-issue-text nb-issue-text--fix">{{
                      issue.fix
                    }}</span>
                  </div>
                  <p class="nb-issue-reason">{{ issue.reason }}</p>
                </div>
              </div>
            </div>
          </div>

          <div class="nb-modal-actions">
            <button class="nb-btn nb-btn--secondary" @click="closeModal">
              Dismiss
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=Bebas+Neue&display=swap");

/* ── Base ── */
.nb-root {
  font-family: "Space Mono", monospace;
  background: #cfe4e6;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 2rem;
  box-sizing: border-box;
  position: relative;
}

/* ── Card ── */
.nb-card {
  background: #fff;
  border: 3px solid #000;
  box-shadow: 8px 8px 0px #000;
  padding: 2.5rem;
  width: 100%;
  max-width: 600px;
}

/* ── Typography ── */
.nb-title {
  font-family: "Bebas Neue", sans-serif;
  font-size: 3.5rem;
  letter-spacing: 2px;
  color: #000;
  line-height: 1;
  margin: 0 0 0.25rem;
}
.nb-title span {
  background: #000;
  color: #05c6db;
  padding: 0 8px;
  display: inline-block;
}
.nb-desc {
  font-size: 0.75rem;
  color: #444;
  margin: 0.75rem 0 2rem;
  line-height: 1.7;
  border-left: 3px solid #000;
  padding-left: 0.75rem;
}
.nb-label {
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  margin-bottom: 0.5rem;
  display: block;
}
.nb-badge {
  display: inline-block;
  background: #cfe4e6;
  border: 2px solid #000;
  font-size: 0.6rem;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
  padding: 2px 8px;
  margin-left: 8px;
  vertical-align: middle;
  position: relative;
  top: -2px;
}
.nb-footer {
  margin-top: 1.5rem;
  font-size: 0.65rem;
  color: #555;
  letter-spacing: 1px;
  text-align: right;
}
.nb-footer-insta {
  color: #000;
  font-weight: 700;
}
.nb-error {
  color: #d9534f;
  font-size: 0.75rem;
  margin-bottom: 0.25rem;
}
.nb-error--recording {
  margin-top: 0.5rem;
  border-left: 3px solid #d9534f;
  padding-left: 0.5rem;
}

/* ── Input ── */
.nb-input-container {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.nb-textarea {
  width: 100%;
  padding: 0.75rem;
  font-family: "Space Mono", monospace;
  font-size: 0.85rem;
  border: 3px solid #000;
  background: #cfe4e6;
  resize: vertical;
  box-sizing: border-box;
  outline: none;
  line-height: 1.6;
  transition: box-shadow 0.1s;
}
.nb-textarea:focus {
  box-shadow: 4px 4px 0 #000;
}
.nb-textarea:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ── Button row ── */
.nb-btn-container {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

/* ── Button ── */
.nb-btn {
  margin-top: 1.25rem;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: #000;
  color: #05c6db;
  font-family: "Space Mono", monospace;
  font-weight: 700;
  font-size: 0.85rem;
  letter-spacing: 2px;
  text-transform: uppercase;
  border: 3px solid #000;
  padding: 0.75rem 2rem;
  cursor: pointer;
  box-shadow: 4px 4px 0 #555;
  transition:
    box-shadow 0.1s,
    transform 0.1s;
}
.nb-btn:hover:not(:disabled) {
  box-shadow: 6px 6px 0 #333;
  transform: translate(-1px, -1px);
}
.nb-btn:active:not(:disabled) {
  box-shadow: 1px 1px 0 #000;
  transform: translate(3px, 3px);
}
.nb-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
  box-shadow: 2px 2px 0 #555;
}
.nb-btn--secondary {
  background: #fff;
  color: #000;
  box-shadow: 4px 4px 0 #aaa;
}
.nb-btn--secondary:hover:not(:disabled) {
  box-shadow: 6px 6px 0 #888;
  transform: translate(-1px, -1px);
}
.nb-btn-clear {
  margin-top: 1.25rem;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: #ffb303;
  color: #ffffff;
  font-family: "Space Mono", monospace;
  font-weight: 700;
  font-size: 0.85rem;
  letter-spacing: 2px;
  text-transform: uppercase;
  border: 3px solid #000;
  padding: 0.75rem 2rem;
  cursor: pointer;
  box-shadow: 4px 4px 0 #555;
  transition:
    box-shadow 0.1s,
    transform 0.1s;
}
.nb-btn-clear:hover:not(:disabled) {
  box-shadow: 6px 6px 0 #333;
  transform: translate(-1px, -1px);
}
.nb-btn-clear:active:not(:disabled) {
  box-shadow: 1px 1px 0 #000;
  transform: translate(3px, 3px);
}

/* ── Record button ── */
.nb-btn--record {
  background: #fff;
  color: #000;
  border-color: #000;
  box-shadow: 4px 4px 0 #555;
  position: relative;
  overflow: hidden;
}
.nb-btn--record:hover:not(:disabled) {
  background: #fff0f0;
  box-shadow: 6px 6px 0 #333;
  transform: translate(-1px, -1px);
}
.nb-btn--recording {
  background: #000 !important;
  color: #ff3b3b !important;
  border-color: #ff3b3b !important;
  box-shadow: 4px 4px 0 #ff3b3b !important;
  animation: rec-border-pulse 1s ease-in-out infinite;
}
@keyframes rec-border-pulse {
  0%,
  100% {
    box-shadow: 4px 4px 0 #ff3b3b;
  }
  50% {
    box-shadow: 6px 6px 0 #ff3b3b;
  }
}

/* Blinking dot */
.nb-rec-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #000;
  flex-shrink: 0;
}
.nb-rec-dot--active {
  background: #ff3b3b;
  animation: blink-dot 0.8s step-start infinite;
}
@keyframes blink-dot {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0;
  }
}

/* ── Recording live banner ── */
.nb-recording-banner {
  margin-top: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  background: #000;
  border: 2px solid #ff3b3b;
  padding: 0.6rem 1rem;
  box-shadow: 4px 4px 0 #ff3b3b;
}
.nb-recording-label {
  font-size: 0.65rem;
  font-weight: 700;
  letter-spacing: 3px;
  text-transform: uppercase;
  color: #ff3b3b;
}
.nb-recording-bars {
  display: flex;
  align-items: center;
  gap: 3px;
  height: 20px;
}
.nb-recording-bars span {
  display: block;
  width: 4px;
  background: #ff3b3b;
  animation: wave 0.7s ease-in-out infinite alternate;
}
.nb-recording-bars span:nth-child(1) {
  animation-delay: 0s;
  height: 6px;
}
.nb-recording-bars span:nth-child(2) {
  animation-delay: 0.1s;
  height: 14px;
}
.nb-recording-bars span:nth-child(3) {
  animation-delay: 0.2s;
  height: 20px;
}
.nb-recording-bars span:nth-child(4) {
  animation-delay: 0.3s;
  height: 10px;
}
.nb-recording-bars span:nth-child(5) {
  animation-delay: 0.4s;
  height: 16px;
}
.nb-recording-bars--mirror span:nth-child(1) {
  animation-delay: 0.4s;
}
.nb-recording-bars--mirror span:nth-child(2) {
  animation-delay: 0.3s;
}
.nb-recording-bars--mirror span:nth-child(3) {
  animation-delay: 0.2s;
}
.nb-recording-bars--mirror span:nth-child(4) {
  animation-delay: 0.1s;
}
.nb-recording-bars--mirror span:nth-child(5) {
  animation-delay: 0s;
}
@keyframes wave {
  from {
    transform: scaleY(0.3);
  }
  to {
    transform: scaleY(1);
  }
}

/* ── Spinner inside button ── */
.nb-btn-loading {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}
.nb-spinner {
  display: inline-block;
  width: 12px;
  height: 12px;
  border: 2px solid #05c6db;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* ── Overlay ── */
.nb-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
  padding: 1.5rem;
  box-sizing: border-box;
  backdrop-filter: blur(2px);
}

/* ── Loading box ── */
.nb-overlay-inner {
  display: flex;
  align-items: center;
  justify-content: center;
}
.nb-loading-box {
  background: #fff;
  border: 3px solid #000;
  box-shadow: 8px 8px 0 #000;
  padding: 2rem 2.5rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.25rem;
}
.nb-loading-bars {
  display: flex;
  align-items: flex-end;
  gap: 5px;
  height: 36px;
}
.nb-loading-bars span {
  display: block;
  width: 8px;
  background: #000;
  animation: bar-bounce 0.9s ease-in-out infinite;
}
.nb-loading-bars span:nth-child(1) {
  animation-delay: 0s;
  height: 20px;
}
.nb-loading-bars span:nth-child(2) {
  animation-delay: 0.15s;
  height: 30px;
}
.nb-loading-bars span:nth-child(3) {
  animation-delay: 0.3s;
  height: 24px;
}
.nb-loading-bars span:nth-child(4) {
  animation-delay: 0.45s;
  height: 36px;
}
@keyframes bar-bounce {
  0%,
  100% {
    transform: scaleY(0.4);
    background: #000;
  }
  50% {
    transform: scaleY(1);
    background: #05c6db;
  }
}
.nb-loading-text {
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 3px;
  text-transform: uppercase;
  margin: 0;
}

/* ── Modal ── */
.nb-modal {
  background: #fff;
  border: 3px solid #000;
  box-shadow: 10px 10px 0 #000;
  width: 100%;
  max-width: 640px;
  max-height: 85vh;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  padding: 2rem;
  box-sizing: border-box;
}
.nb-modal-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
}
.nb-modal-title {
  font-family: "Bebas Neue", sans-serif;
  font-size: 2.5rem;
  letter-spacing: 2px;
  margin: 0;
  line-height: 1;
}
.nb-modal-title span {
  background: #000;
  color: #05c6db;
  padding: 0 6px;
}
.nb-close-btn {
  background: none;
  border: 2px solid #000;
  font-family: "Space Mono", monospace;
  font-size: 0.75rem;
  font-weight: 700;
  cursor: pointer;
  padding: 4px 8px;
  line-height: 1;
  flex-shrink: 0;
  transition:
    background 0.1s,
    color 0.1s;
}
.nb-close-btn:hover {
  background: #000;
  color: #fff;
}
.nb-issues-meta {
  display: flex;
  align-items: center;
}
.nb-issues-badge {
  font-size: 0.65rem;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  background: #000;
  color: #05c6db;
  padding: 4px 12px;
  border: 2px solid #000;
}
.nb-issues-badge--none {
  background: #cfe4e6;
  color: #000;
}
.nb-section {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
}
.nb-section-label {
  font-size: 0.65rem;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  margin: 0;
}
.nb-corrected-box {
  background: #cfe4e6;
  border: 2px solid #000;
  padding: 0.85rem 1rem;
  font-size: 0.82rem;
  line-height: 1.7;
  white-space: pre-wrap;
}
.nb-issues-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.nb-issue-card {
  border: 2px solid #000;
  display: flex;
  gap: 0;
  overflow: hidden;
}
.nb-issue-index {
  background: #000;
  color: #05c6db;
  font-family: "Bebas Neue", sans-serif;
  font-size: 1.6rem;
  letter-spacing: 1px;
  padding: 0.75rem 0.85rem;
  display: flex;
  align-items: center;
  flex-shrink: 0;
  line-height: 1;
}
.nb-issue-body {
  padding: 0.75rem 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  flex: 1;
  min-width: 0;
}
.nb-issue-row {
  display: flex;
  align-items: baseline;
  gap: 0.6rem;
  flex-wrap: wrap;
}
.nb-issue-pill {
  font-size: 0.55rem;
  font-weight: 700;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  padding: 2px 6px;
  border: 1.5px solid #000;
  flex-shrink: 0;
}
.nb-issue-pill--original {
  background: #fff0f0;
  color: #b00;
  border-color: #b00;
}
.nb-issue-pill--fix {
  background: #f0fff4;
  color: #060;
  border-color: #060;
}
.nb-issue-text {
  font-size: 0.8rem;
  line-height: 1.5;
}
.nb-issue-text--original {
  text-decoration: line-through;
  color: #b00;
}
.nb-issue-text--fix {
  color: #060;
  font-weight: 700;
}
.nb-issue-reason {
  font-size: 0.72rem;
  color: #555;
  margin: 0.15rem 0 0;
  line-height: 1.6;
  border-top: 1px dashed #ccc;
  padding-top: 0.4rem;
}
.nb-modal-actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
  border-top: 2px solid #000;
  padding-top: 1rem;
}
.nb-modal-actions .nb-btn {
  margin-top: 0;
  flex: 1;
  justify-content: center;
}

/* ── Transitions ── */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
.modal-enter-active {
  transition: opacity 0.2s ease;
}
.modal-enter-active .nb-modal {
  animation: modal-pop 0.25s cubic-bezier(0.34, 1.4, 0.64, 1) both;
}
.modal-leave-active {
  transition: opacity 0.15s ease;
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
@keyframes modal-pop {
  from {
    transform: translateY(16px) scale(0.97);
    opacity: 0;
  }
  to {
    transform: translateY(0) scale(1);
    opacity: 1;
  }
}
</style>
