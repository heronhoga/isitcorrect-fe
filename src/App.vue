<script setup lang="ts"></script>

<template>
  <div class="nb-root">
    <div class="nb-card">
      <h1 class="nb-title">Is It <span>Correct?</span></h1>
      <p class="nb-desc">
        Simple grammar corrector — in case you need help with your writing in an
        immediate way.
        <span class="nb-badge">by hg</span>
      </p>

      <label class="nb-label" for="grammar-input">Your text</label>
      <textarea
        id="grammar-input"
        class="nb-textarea"
        rows="10"
        placeholder="Type your text here..."
      ></textarea>

      <div>
        <button class="nb-btn" type="button">✦ Check Grammar</button>
      </div>

      <p class="nb-footer">no data stored. no fluff. just corrections.</p>
    </div>
  </div>
</template>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=Bebas+Neue&display=swap");

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
}

.nb-card {
  background: #fff;
  border: 3px solid #000;
  box-shadow: 8px 8px 0px #000;
  padding: 2.5rem;
  width: 100%;
  max-width: 600px;
}

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

.nb-btn {
  margin-top: 1.25rem;
  display: inline-block;
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

.nb-btn:hover {
  box-shadow: 6px 6px 0 #333;
  transform: translate(-1px, -1px);
}

.nb-btn:active {
  box-shadow: 1px 1px 0 #000;
  transform: translate(3px, 3px);
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
</style>
