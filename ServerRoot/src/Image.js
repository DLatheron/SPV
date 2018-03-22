'use strict';

export class Image {
    constructor({ name, title, alt = 'TODO', thumbnailUrl, resourceUrl, width, height }) {
        this.name = name;
        this.title = title;
        this.alt = alt;
        this.thumbnailUrl = thumbnailUrl;
        this.resourceUrl = resourceUrl;
        this.width = width;
        this.height = height;
        this.fitToAspect = true;
    }

    resizeTo(width = 128, height = 128, fitToAspect = true) {
        if (fitToAspect) {
            if (this.width > this.height) {
                this.thumbnailWidth = width;
                this.thumbnailHeight = height * this.height / this.width;
            } else {
                this.thumbnailWidth = width * this.width / this.height;
                this.thumbnailHeight = height;
            }
        } else {
            this.thumbnailWidth = width;
            this.thumbnailHeight = height;
        }

        this.fitToAspect = fitToAspect;
    }

    addToElement(element) {
        element
            .append(`
<div class="img">
    <a target="_blank" href="${this.resourceUrl}">
    <img src="${this.thumbnailUrl}" alt="${this.alt}" width="${this.thumbnailWidth}" height="${this.thumbnailHeight}" title="${this.title}" /></a>
</div>`);
    }
}
