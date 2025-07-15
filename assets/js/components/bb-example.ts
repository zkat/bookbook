import { css, html, LitElement } from "lit";
import { customElement, property } from "lit/decorators.js";

// These styles will be bundled with the global CSS, and unscoped.
import "./bb-example.css";

@customElement("bb-example")
export class BbExample extends LitElement {
  // These styles will be scoped to shadow DOM.
  static styles = css`
    :host {
      color: var(--background-color, green);
    }
  `;

  // Render into light DOM instead of a shadow root.
  // createRenderRoot() {
  //   return this;
  // }

  @property()
  text?: string;

  render() {
    return html`
      <div class="example">
        <h1>Example Component</h1>
        <p>This is an example component with text ${this.text}.</p>
      </div>
    `;
  }
}
