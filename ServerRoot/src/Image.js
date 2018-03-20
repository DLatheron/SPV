'use strict';

export class Image {
    constructor({ thumbnailUrl, resourceUrl, alt = 'TODO', width = 128, height = 128 }) {
        this.thumbnailUrl = thumbnailUrl;
        this.resourceUrl = resourceUrl;
        this.alt = alt;
        this.width = width;
        this.height = height;
    }

    addToElement(element) {
        element
            .append(`
<div class="img">
    <a target="_blank" href="${this.url}">
    <img src="${this.thumbnailUrl}" alt="${this.alt}" width="${this.width}" height="${this.height}" /></a>
</div>`);
    }
}
