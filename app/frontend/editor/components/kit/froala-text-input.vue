<template>
  <div>
    <div class="block font-semibold text-gray-800 mb-2">
      {{ label }}
    </div>

    <button
      type="button"
      class="froala-open-btn"
      @click="openEditor"
    >
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
      Open Full Editor
    </button>

    <!-- Froala Modal -->
    <div v-if="showModal" class="froala-modal-overlay" @click.self="closeEditor">
      <div class="froala-modal-container">
        <div class="froala-modal-header">
          <h3>{{ label }}</h3>
          <div class="froala-modal-header-actions">
            <button class="froala-modal-btn froala-modal-btn-cancel" @click="closeEditor">Cancel</button>
            <button class="froala-modal-btn froala-modal-btn-save" @click="saveAndClose">Apply Changes</button>
          </div>
        </div>
        <div class="froala-modal-body">
          <div ref="froalaContainer">
            <textarea ref="froalaTextarea"></textarea>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import FocusedInputMixin from '@/mixins/focused-input'

export default {
  name: 'UIKitFroalaTextInput',
  mixins: [FocusedInputMixin],
  props: {
    label: { type: String, default: 'Label' },
    name: { type: String, default: 'text' },
    value: { type: String },
    lineBreak: { type: Boolean, default: false },
    rows: { type: Number, default: 2 },
    extraExtensions: { type: Object, default: () => ({}) },
  },
  data() {
    return {
      showModal: false,
      froalaInstance: null,
      froalaLoaded: false,
    }
  },
  mounted() {
    this.loadFroalaAssets()
  },
  beforeDestroy() {
    this.destroyFroala()
  },
  methods: {
    loadFroalaAssets() {
      if (window.FroalaEditor) {
        this.froalaLoaded = true
        return
      }
      // Load CSS
      this.loadCSS('https://cdn.jsdelivr.net/npm/froala-editor@latest/css/froala_editor.pkgd.min.css')
      this.loadCSS('https://cdn.jsdelivr.net/npm/froala-editor@latest/css/froala_style.min.css')
      // Load JS
      const script = document.createElement('script')
      script.src = 'https://cdn.jsdelivr.net/npm/froala-editor@latest/js/froala_editor.pkgd.min.js'
      script.onload = () => { this.froalaLoaded = true }
      document.head.appendChild(script)
    },

    loadCSS(href) {
      if (document.querySelector(`link[href="${href}"]`)) return
      const link = document.createElement('link')
      link.rel = 'stylesheet'
      link.href = href
      document.head.appendChild(link)
    },

    openEditor() {
      this.showModal = true
      this.$nextTick(() => {
        this.waitForFroalaAndInit()
      })
    },

    waitForFroalaAndInit() {
      if (this.froalaLoaded && window.FroalaEditor) {
        this.initFroala()
      } else {
        setTimeout(() => this.waitForFroalaAndInit(), 200)
      }
    },

    initFroala() {
      this.destroyFroala()
      const textarea = this.$refs.froalaTextarea
      if (!textarea) return

      textarea.value = this.value || ''

      this.froalaInstance = new window.FroalaEditor(textarea, {
        key: window.maglev_froala_key || '',
        attribution: false,
        heightMin: 400,
        heightMax: 600,
        imageUploadURL: '/maglev/froala/images',
        imageUploadMethod: 'POST',
        imageUploadParam: 'file',
        imageMaxSize: 10 * 1024 * 1024,
        imageAllowedTypes: ['jpeg', 'jpg', 'png', 'gif', 'webp', 'svg'],
        imageEditButtons: [
          'imageReplace', 'imageAlign', 'imageCaption', 'imageRemove',
          'imageLink', 'imageDisplay', 'imageStyle', 'imageAlt', 'imageSize'
        ],
        videoUpload: false,
        fileUpload: false,
        toolbarButtons: {
          moreText: {
            buttons: [
              'bold', 'italic', 'underline', 'strikeThrough',
              'subscript', 'superscript', 'fontSize', 'textColor',
              'backgroundColor', 'clearFormatting'
            ],
            buttonsVisible: 7
          },
          moreParagraph: {
            buttons: [
              'alignLeft', 'alignCenter', 'alignRight', 'alignJustify',
              'formatOL', 'formatUL', 'paragraphFormat', 'lineHeight',
              'outdent', 'indent', 'quote'
            ],
            buttonsVisible: 6
          },
          moreRich: {
            buttons: [
              'insertLink', 'insertImage', 'insertTable',
              'insertHR', 'specialCharacters'
            ],
            buttonsVisible: 5
          },
          moreMisc: {
            buttons: ['undo', 'redo', 'fullscreen', 'html'],
            buttonsVisible: 4
          }
        },
      })
    },

    saveAndClose() {
      if (this.froalaInstance) {
        const html = this.froalaInstance.html.get()
        this.$emit('input', html)
      }
      this.closeEditor()
    },

    closeEditor() {
      this.destroyFroala()
      this.showModal = false
    },

    destroyFroala() {
      if (this.froalaInstance) {
        try { this.froalaInstance.destroy() } catch(e) {}
        this.froalaInstance = null
      }
    },
  },
}
</script>

<!-- Unscoped styles for Froala's content editing area -->
<style>
.froala-modal-body .fr-element {
  font-family: ui-sans-serif, system-ui, -apple-system, sans-serif;
  font-size: 16px;
  line-height: 1.75;
  color: #1f2937;
  padding: 24px 32px;
}
.froala-modal-body .fr-element h1 {
  font-size: 2.25rem;
  font-weight: 800;
  margin: 1.5rem 0 0.75rem;
  line-height: 1.2;
}
.froala-modal-body .fr-element h2 {
  font-size: 1.875rem;
  font-weight: 700;
  margin: 1.25rem 0 0.625rem;
  line-height: 1.3;
}
.froala-modal-body .fr-element h3 {
  font-size: 1.5rem;
  font-weight: 600;
  margin: 1rem 0 0.5rem;
  line-height: 1.4;
}
.froala-modal-body .fr-element h4 {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0.75rem 0 0.5rem;
}
.froala-modal-body .fr-element p {
  margin: 0.75rem 0;
}
.froala-modal-body .fr-element img {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
}
.froala-modal-body .fr-element blockquote {
  border-left: 4px solid #e5e7eb;
  padding-left: 1rem;
  color: #6b7280;
  font-style: italic;
  margin: 1rem 0;
}
.froala-modal-body .fr-element ul,
.froala-modal-body .fr-element ol {
  padding-left: 1.5rem;
  margin: 0.75rem 0;
}
.froala-modal-body .fr-element table {
  width: 100%;
  border-collapse: collapse;
  margin: 1rem 0;
}
.froala-modal-body .fr-element table td,
.froala-modal-body .fr-element table th {
  border: 1px solid #e5e7eb;
  padding: 8px 12px;
}
</style>

<style scoped>
.froala-open-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  width: 100%;
  margin-top: 8px;
  padding: 8px 12px;
  font-size: 12px;
  font-weight: 600;
  color: #ee6840;
  background: #fff5f0;
  border: 1px solid #fed7cc;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.15s;
}
.froala-open-btn:hover {
  background: #fee5db;
  border-color: #ee6840;
}

.froala-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.6);
  z-index: 99999;
  display: flex;
  align-items: center;
  justify-content: center;
}
.froala-modal-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 25px 50px rgba(0,0,0,0.3);
  width: 900px;
  max-width: 95vw;
  max-height: 90vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
.froala-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 20px;
  border-bottom: 1px solid #e5e7eb;
  background: #f9fafb;
  border-radius: 12px 12px 0 0;
}
.froala-modal-header h3 {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
}
.froala-modal-header-actions {
  display: flex;
  gap: 8px;
}
.froala-modal-body {
  flex: 1;
  overflow-y: auto;
}
.froala-modal-btn {
  padding: 7px 16px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: all 0.15s;
}
.froala-modal-btn-cancel {
  background: #e5e7eb;
  color: #374151;
}
.froala-modal-btn-cancel:hover { background: #d1d5db; }
.froala-modal-btn-save {
  background: #ee6840;
  color: white;
}
.froala-modal-btn-save:hover { background: #dc5530; }
</style>
