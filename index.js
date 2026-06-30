const display = document.querySelector("[data-display]");
const keys = document.querySelector("[data-keys]");
const scientificPanel = document.querySelector("[data-scientific]");
const historyElement = document.querySelector("[data-history]");
const memoryDisplay = document.querySelector("[data-memory-display]");

const MAX_LEN = 64;
let memory = 0;
let history = [];

function isSafe(expression) {
  return /^[0-9+\-*/().\s]*$/.test(expression);
}

function setDisplayValue(nextValue) {
  display.value = nextValue.slice(0, MAX_LEN);
}

function appendValue(value) {
  if (display.value.length >= MAX_LEN) return;
  setDisplayValue(display.value + value);
}

function clearAll() {
  setDisplayValue("");
}

function backspace() {
  setDisplayValue(display.value.slice(0, -1));
}

function evaluateExpr() {
  const raw = display.value.trim();
  if (!raw) return;
  if (!isSafe(raw) && !raw.includes("Math.")) {
    setDisplayValue("Error");
    return;
  }

  try {
    const result = Function(`"use strict"; return (${raw.replace(/\s+/g, "")});`)();
    if (!Number.isFinite(result)) {
      setDisplayValue("Error");
      return;
    }

    const resultStr = String(result);
    addToHistory(`${raw} = ${resultStr}`);
    setDisplayValue(resultStr);
  } catch {
    setDisplayValue("Error");
  }
}

function addToHistory(entry) {
  history.unshift(entry);
  if (history.length > 20) history.pop();
  updateHistoryDisplay();
}

function updateHistoryDisplay() {
  historyElement.innerHTML = history
    .map((item, idx) => `<div class="history-item" data-history-index="${idx}">${item}</div>`)
    .join("");

  document.querySelectorAll(".history-item").forEach(item => {
    item.addEventListener("click", () => {
      const text = item.textContent.split(" = ")[1] || item.textContent;
      setDisplayValue(text);
    });
  });
}

function clearHistory() {
  history = [];
  updateHistoryDisplay();
}

function memoryAdd() {
  try {
    const val = parseFloat(display.value) || 0;
    memory += val;
    updateMemoryDisplay();
    clearAll();
  } catch {
    setDisplayValue("Error");
  }
}

function memorySubtract() {
  try {
    const val = parseFloat(display.value) || 0;
    memory -= val;
    updateMemoryDisplay();
    clearAll();
  } catch {
    setDisplayValue("Error");
  }
}

function memoryRecall() {
  setDisplayValue(String(memory));
}

function memoryClear() {
  memory = 0;
  updateMemoryDisplay();
}

function updateMemoryDisplay() {
  memoryDisplay.textContent = memory.toFixed(2).replace(/\.?0+$/, "");
}

function toggleScientificMode() {
  scientificPanel.classList.toggle("active");
}

function toggleTheme() {
  document.body.classList.toggle("light-mode");
  const themeToggle = document.querySelector(".theme-toggle");
  themeToggle.textContent = document.body.classList.contains("light-mode") ? "☀️" : "🌙";
  localStorage.setItem("theme", document.body.classList.contains("light-mode") ? "light" : "dark");
}

function applyScienticFunc(action) {
  const val = parseFloat(display.value);
  if (isNaN(val)) {
    setDisplayValue("Error");
    return;
  }

  let result;
  const radians = val * (Math.PI / 180);

  switch (action) {
    case "sin":
      result = Math.sin(radians);
      break;
    case "cos":
      result = Math.cos(radians);
      break;
    case "tan":
      result = Math.tan(radians);
      break;
    case "sqrt":
      result = Math.sqrt(val);
      break;
    case "power":
      result = val * val;
      break;
    case "cube":
      result = val * val * val;
      break;
    case "log":
      result = Math.log10(val);
      break;
    case "ln":
      result = Math.log(val);
      break;
    case "factorial":
      if (val < 0 || val > 170) {
        setDisplayValue("Error");
        return;
      }
      result = 1;
      for (let i = 2; i <= val; i++) result *= i;
      break;
    case "inverse":
      if (val === 0) {
        setDisplayValue("Error");
        return;
      }
      result = 1 / val;
      break;
    default:
      return;
  }

  if (!Number.isFinite(result)) {
    setDisplayValue("Error");
  } else {
    setDisplayValue(String(result));
  }
}

function onKeyPress(valueOrAction) {
  if (display.value === "Error" && valueOrAction !== "clear-all") {
    clearAll();
  }

  switch (valueOrAction) {
    case "clear-all":
      clearAll();
      return;
    case "backspace":
      backspace();
      return;
    case "evaluate":
      evaluateExpr();
      return;
    case "toggle-mode":
      toggleScientificMode();
      return;
    case "toggle-theme":
      toggleTheme();
      return;
    case "clear-history":
      clearHistory();
      return;
    case "memory-add":
      memoryAdd();
      return;
    case "memory-subtract":
      memorySubtract();
      return;
    case "memory-recall":
      memoryRecall();
      return;
    case "memory-clear":
      memoryClear();
      return;
    case "sin":
    case "cos":
    case "tan":
    case "sqrt":
    case "power":
    case "cube":
    case "log":
    case "ln":
    case "factorial":
    case "inverse":
      applyScienticFunc(valueOrAction);
      return;
    default:
      appendValue(valueOrAction);
  }
}

keys?.addEventListener("click", (event) => {
  const target = event.target;
  if (!(target instanceof HTMLElement)) return;
  const button = target.closest("button");
  if (!button) return;

  const action = button.getAttribute("data-action");
  const value = button.getAttribute("data-value");
  if (action) onKeyPress(action);
  else if (value) onKeyPress(value);
});

scientificPanel?.addEventListener("click", (event) => {
  const target = event.target;
  if (!(target instanceof HTMLElement)) return;
  const button = target.closest("button");
  if (!button) return;

  const action = button.getAttribute("data-action");
  const value = button.getAttribute("data-value");
  if (action) onKeyPress(action);
  else if (value) {
    appendValue(value);
  }
});

document.addEventListener("click", (event) => {
  const target = event.target;
  if (!(target instanceof HTMLElement)) return;
  const button = target.closest("button[data-action]");
  if (!button) return;

  const action = button.getAttribute("data-action");
  if (["toggle-mode", "toggle-theme", "clear-history", "memory-add", "memory-subtract", "memory-recall", "memory-clear"].includes(action)) {
    onKeyPress(action);
  }
});

document.addEventListener("keydown", (event) => {
  if (event.ctrlKey || event.metaKey || event.altKey) return;
  const { key, code } = event;

  if (code === "NumpadEnter") {
    event.preventDefault();
    onKeyPress("evaluate");
    return;
  }

  if (key === "Escape") {
    event.preventDefault();
    onKeyPress("clear-all");
    return;
  }

  if (key === "Backspace") {
    event.preventDefault();
    onKeyPress("backspace");
    return;
  }

  if (key === "Enter" || key === "=") {
    event.preventDefault();
    onKeyPress("evaluate");
    return;
  }

  if (/^[0-9()+.]$/.test(key) || key === "+") {
    event.preventDefault();
    onKeyPress(key);
    return;
  }

  if (key === ",") {
    event.preventDefault();
    onKeyPress(".");
    return;
  }

  if (/^[*/-]$/.test(key)) {
    event.preventDefault();
    onKeyPress(key);
    return;
  }

  if (code === "NumpadAdd") {
    event.preventDefault();
    onKeyPress("+");
    return;
  }

  if (code === "NumpadSubtract") {
    event.preventDefault();
    onKeyPress("-");
    return;
  }

  if (code === "NumpadMultiply") {
    event.preventDefault();
    onKeyPress("*");
    return;
  }

  if (code === "NumpadDivide") {
    event.preventDefault();
    onKeyPress("/");
    return;
  }

  if (code === "NumpadDecimal") {
    event.preventDefault();
    onKeyPress(".");
    return;
  }

  if (key === "Delete") {
    event.preventDefault();
    onKeyPress("clear-all");
  }
});

display?.addEventListener("focus", () => {
  const end = display.value.length;
  display.setSelectionRange(end, end);
});

window.addEventListener("load", () => {
  const savedTheme = localStorage.getItem("theme");
  if (savedTheme === "light") {
    document.body.classList.add("light-mode");
    const themeToggle = document.querySelector(".theme-toggle");
    if (themeToggle) themeToggle.textContent = "☀️";
  }
  updateMemoryDisplay();
});
