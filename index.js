const display = document.querySelector("[data-display]");
const keys = document.querySelector("[data-keys]");

const MAX_LEN = 64;

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
  if (!isSafe(raw)) {
    setDisplayValue("Error");
    return;
  }

  try {
    // eslint-disable-next-line no-new-func
    const result = Function(`"use strict"; return (${raw.replace(/\s+/g, "")});`)();
    if (!Number.isFinite(result)) {
      setDisplayValue("Error");
      return;
    }
    setDisplayValue(String(result));
  } catch {
    setDisplayValue("Error");
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

  if (/^[0-9()+.]$/.test(key) || key === "+" || key === ",") {
    event.preventDefault();
    onKeyPress(key === "," ? "." : key);
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
  // Keep caret at end for a calculator-like feel.
  const end = display.value.length;
  display.setSelectionRange(end, end);
});

