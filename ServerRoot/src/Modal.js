'use strict';
/* globals $, window, document */

export class Modal {
    set progress(value) {
        this.progressBar.progressbar('value', value);
    }
    get progress() {
        return this.progressBar.progressbar('value');
    }

    constructor(selector) {
        this.modal = $(selector);
        this.closeSpan = $(`${selector} > close`).first();

        this.text = this.modal.children().find('p');
        this.progressBar = this.modal.children().find('div');

        this.text.text('Compressing selected images...');
        this.progressBar.progressbar({ value: 0 });

        this.modal.show();

        // When the user clicks on <span> (x), close the modal
        this.closeSpan.click = () => {
            this.modal.hide();
        };

        // When the user clicks anywhere outside of the modal, close it
        window.onclick = (event) => {
            if (event.target === this.modal) {
                this.modal.hide();
            }
        };
    }

    close(delayInMs = 0) {
        if (delayInMs) {
            setTimeout(() => {
                this.modal.hide();
            }, delayInMs);
        } else {
            this.modal.hide();
        }
    }
}
