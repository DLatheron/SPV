'use strict';

export class Image {
    constructor({ id, index, name, title, alt = 'TODO', thumbnailUrl, resourceUrl, width, height, imageUrl, videoUrl }) {
        this.id = id;
        this.index = index;
        this.name = name;
        this.title = title;
        this.alt = alt;
        this.thumbnailUrl = thumbnailUrl;
        this.resourceUrl = resourceUrl;
        this.width = width;
        this.height = height;
        this.imageUrl = imageUrl;
        this.videoUrl = videoUrl;
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

        this.containerWidth = width;
        this.containerHeight = height;

        this.fitToAspect = fitToAspect;
    }

    container() {
        if (this.imageUrl && this.videoUrl) {
            return this.livePhotoContainer();
        } else {
            return this.imageContainer();
        }
    }

    imageContainer() {
        const horizontalBorder = (this.containerWidth - this.thumbnailWidth) / 2.0;
        const verticalBorder = (this.containerWidth - this.thumbnailHeight) / 2.0;

        return `
            <img
                src="${this.thumbnailUrl}"
                alt="${this.alt}"
                width="${this.thumbnailWidth}"
                height="${this.thumbnailHeight}"
                title="${this.title}"
                style="
                    margin: 0;
                    padding-top: ${verticalBorder}px;
                    padding-bottom: ${verticalBorder}px;
                    padding-left: ${horizontalBorder}px;
                    padding-right: ${horizontalBorder}px;
                "
            />`;
    }

    livePhotoContainer() {
        const horizontalBorder = (this.containerWidth - this.thumbnailWidth) / 2.0;
        const verticalBorder = (this.containerWidth - this.thumbnailHeight) / 2.0;

        return `
            <span
                id="${this.id}"
                class="livePhoto"
                data-live-photo
                data-photo-mime-type="image/jpeg"
                data-video-mime-type="video/quicktime"
                width="${this.thumbnailWidth}"
                height="${this.thumbnailHeight}"
                data-photo-src="${this.imageUrl}"
                data-video-src="${this.videoUrl}"
                style="
                    margin: 0;
                    width: ${this.thumbnailWidth}px;
                    height: ${this.thumbnailHeight}px;
                    padding-top: ${verticalBorder}px;
                    padding-bottom: ${verticalBorder}px;
                    padding-left: ${horizontalBorder}px:
                    padding-right: ${horizontalBorder}px;
                "
            </span>`;
    }

    addToElement(element) {
        const bottomHeight = 20;
        const checkboxInset = 20;
        const container = this.containerWidth + 16;
        const containerHeight = this.containerHeight + 16 + bottomHeight;

        element
            .append(`
<div class="img" style="width: ${container}px; height: ${containerHeight}px;">
    <a target="_blank" href="${this.resourceUrl}">
        ${this.container()}
    </a>
    <div
        class="title"
        style="
            width: ${this.containerWidth}px;
            height: ${bottomHeight}px
        "
    >
        <input
            type="checkbox"
            type="checkbox"
            value="selection"
            class="checkbox"
            index="${this.index}"
        />
        <label
            for="selection"
            style="width: ${this.containerWidth - checkboxInset}px"
        >${this.name}</label>
    </div>
</div>`);
    }
}
