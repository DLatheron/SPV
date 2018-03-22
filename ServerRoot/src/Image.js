'use strict';

export class Image {
    constructor({ name, title, thumbnailUrl, resourceUrl, alt = 'TODO', width = 128, height = 128 }) {
        this.name = name;
        this.title = title;
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
    <a target="_blank" href="${this.resourceUrl}">
    <img src="${this.thumbnailUrl}" alt="${this.alt}" width="${this.width}" height="${this.height}" title="${this.title}" /></a>
</div>`);
    }
}
