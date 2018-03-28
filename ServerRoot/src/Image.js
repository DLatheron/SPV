'use strict';

export class Image {
    constructor({ index, name, title, alt = 'TODO', thumbnailUrl, resourceUrl, width, height }) {
        this.index = index;
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
        const horizontalWidth = this.thumbnailWidth + 16;
        const verticalWidth = horizontalWidth + 20;

        element
            .append(`
<div class="img" style="width: ${horizontalWidth}px; height: ${verticalWidth}px;">
    <a target="_blank" href="${this.resourceUrl}">
    <img src="${this.thumbnailUrl}" alt="${this.alt}" width="${this.thumbnailWidth}" height="${this.thumbnailHeight}" title="${this.title}" /></a>
    <div class="title" style="width: ${this.thumbnailWidth}px; height: ${verticalWidth - this.thumbnailHeight - 20}px">
        <input type="checkbox" type="checkbox" value="selection" class="checkbox" index="${this.index}" />
        <label for="selection">${this.name}</label>
    </div>
</div>`);
    }
}
