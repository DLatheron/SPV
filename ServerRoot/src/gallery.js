'use strict';
/* globals $, _, alert */

import { ImageStore } from '/src/ImageStore.js';
import { Modal } from '/src/Modal.js';
import { ImageDownloader } from '/src/ImageDownloader.js';

export class Gallery {
    constructor() {
        this.imageStore = new ImageStore();
        this.selection = {};

        this.quantities = [
            { value: 1 },
            { value: 2 },
            { value: 3 },
            { value: 4 },
            { value: 5 },
            { value: 10, default: true },
            { value: 20 },
            { value: 'all' }
        ];
        this.sortByItems = [
            { value: 'name', default: true },
            { value: 'date' },
            { value: 'size' },
            { value: 'rating' }
        ];
        this.directionItems = [
            { value: 'ascending', default: true },
            { value: 'descending' }
        ];
        this.thumbnailSizes = [
            { value:  64, text: 'tiny' },
            { value: 128, text: 'small', default: true },
            { value: 256, text: 'medium' },
            { value: 512, text: 'large' },
        ];
        this.displayModes = [
            { value: 'aspect', default: true },
            { value: 'crop' }
        ];
        this.imageRanges = [];

        $('#sortBy').change(this.onSortByChange.bind(this));
        $('#direction').change(this.onDirectionChange.bind(this));
        $('#quantity')
            .on('focus', () => {
                this.previousQuantity = parseInt(this.value);
            })
            .change((event) => {
                this.onQuantityChange(event, this.previousFirstImage);
                this.previousQuantity = parseInt(this.value);
            });

        $('#imageRange')
            .on('focus', () => {
                this.previousFirstImage = parseInt(this.value);
            })
            .change((event) => {
                this.onImageRangeChange(event);
                this.previousFirstImage = parseInt(this.value);
            });
        $('#size').change(this.onSizeChange.bind(this));
        $('#displayMode').change(this.onDisplayModeChamge.bind(this));
        $('#first').click(this.onFirstClick.bind(this));
        $('#prev').click(this.onPrevClick.bind(this));
        $('#next').click(this.onNextClick.bind(this));
        $('#last').click(this.onLastClick.bind(this));

        $('#selectAll').click(this.onSelectAllClick.bind(this));
        $('#selectNone').click(this.onSelectNoneClick.bind(this));
        $('#selectInvert').click(this.onSelectInvertClick.bind(this));
        $('#downloadSelected').click(this.onDownloadSelectedClick.bind(this));
        $('#downloadAll').click(this.onDownloadAllClick.bind(this));

        this.populateSelectBox('#sortBy', this.sortByItems);
        this.populateSelectBox('#direction', this.directionItems);
        this.populateSelectBox('#quantity', this.quantities);
        this.populateSelectBox('#size', this.thumbnailSizes);
        this.populateSelectBox('#displayMode', this.displayModes);

        // $('#sortBy').val('name');
        // $('#direction').val('ascending');
        // $('#quantity').val(10);
        // $('#size').val(128);

        this.imageStore.getImageTotals((error) => {
            this.updateImageRanges(0, this.imageStore.totalImages);

            this.requestImages();
        });
    }

    getSortBy() {
        return $('#sortBy').first().val();
    }

    getDirection() {
        return $('#direction').first().val();
    }

    getQuantity() {
        let quantity = $('#quantity').first().val();
        if (quantity === 'all') {
            return this.imageStore.totalImages;
        } else {
            return parseInt(quantity);
        }
    }

    getImageRange() {
        return parseInt($('#imageRange').first().val() || 0);
    }

    getSize() {
        return parseInt($('#size').first().val());
    }

    getDisplayMode() {
        return $('#displayMode').first().val();
    }

    onSortByChange(event) {
        this.requestImages();
    }

    onDirectionChange(event) {
        this.requestImages();
    }

    onQuantityChange(event, previousFirstImage) {
        this.updateImageRanges(previousFirstImage, this.getQuantity());
        this.requestImages();
    }

    onImageRangeChange(event) {
        this.requestImages();
    }

    onSizeChange(event) {
        this.refreshImages();
    }

    onDisplayModeChamge(event) {
        this.refreshImages();
    }

    makeOption({ value, text }) {
        text = text || value;
        return `<option value='${value}'>${text}</option>`;
    }

    formatRange(startImage, endImage, maxDigits) {
        const nbspPadding = ' '; // <-- Alt-Enter for nbsp.
        const first = `${startImage + 1}`.padStart(maxDigits, nbspPadding);
        if (startImage >= (endImage - 1)) {
            return first;
        } else {
            const second = `${endImage}`.padEnd(maxDigits, nbspPadding);

            return `${first} - ${second}`;
        }
    }

    updateImageRanges(offset, quantity) {
        const batchSize = this.getQuantity();
        const maxDigits = this.imageStore.totalImages.length;
        this.imageRanges = [];

        for (
            let startImage = 0;
            startImage < this.imageStore.totalImages;
            startImage += batchSize
        ) {
            const endImage = Math.min(startImage + batchSize, this.imageStore.totalImages);
            const imageRange = this.formatRange(startImage, endImage, maxDigits);
            this.imageRanges.push({ value: startImage, text: imageRange });
        }

        this.populateSelectBox('#imageRange', this.imageRanges);

        this.selectImageRangeForOffset(offset, quantity);
    }

    selectImageRangeForOffset(offset, quantity) {
        if (offset === undefined) {
            return;
        }

        const rangeToSelect = this.imageRanges.find(range => {
            const startImage = range.value;
            const endImage = Math.min(startImage + quantity, this.imageStore.totalImages + 1);
            return (offset >= startImage && offset < endImage);
        });

        if (rangeToSelect) {
            const startImage = rangeToSelect.value;
            const endImage = Math.min(startImage + quantity, this.imageStore.totalImages + 1);
            $('#imageRange').val(startImage);
        }
    }

    requestImages() {
        const sortBy = this.getSortBy();
        const direction = this.getDirection();
        const quantity = this.getQuantity();
        const offset = this.getImageRange();

        this.imageStore.getImages(sortBy, direction, offset, quantity, (error) => {
            this.refreshImages();
        });
    }

    refreshImages() {
        const dimension = this.getSize();
        const displayMode = this.getDisplayMode();

        this.imageStore.resizeImagesTo(dimension, dimension, (displayMode === 'aspect'));

        const galleryDiv = $('#gallery').first();
        galleryDiv.empty();
        this.imageStore.addToElement(galleryDiv);

        $('input.checkbox').click(this.onCheckboxClick.bind(this));
        this.refreshUISelection();
    }

    populateSelectBox(selector, options) {
        const selectBox = $(selector);
        selectBox.empty();
        options.forEach(item => selectBox.append(this.makeOption(item)));

        this.refreshUIState();

        const defaultOption = options.find(item => item.default);
        if (defaultOption) {
            selectBox.val(defaultOption.value);
        }
    }

    get firstImageRange() {
        return parseInt($('#imageRange').children().first().val());
    }

    get lastImageRange() {
        return parseInt($('#imageRange').children().last().val());
    }

    get isFirstImageRange() {
        return (this.getImageRange() === this.firstImageRange);
    }

    get isLastImageRange() {
        return (this.getImageRange() === this.lastImageRange);
    }

    onFirstClick(event) {
        const imageRange = $('#imageRange');
        const offset = parseInt(imageRange.children().first().val());
        imageRange.val(offset);
        this.requestImages();
        this.refreshUIState();
    }

    onPrevClick(event) {
        if (!this.isFirstImageRange) {
            const offset = Math.max(this.getImageRange() - this.getQuantity(), 0);
            $('#imageRange').val(offset);
            this.requestImages();
            this.refreshUIState();
        }
    }

    onNextClick(event)  {
        if (!this.isLastImageRange) {
            const offset = Math.min(this.getImageRange() + this.getQuantity(), (this.imageStore.totalImages - 1));
            $('#imageRange').val(offset);
            this.requestImages();
            this.refreshUIState();
        }
    }

    onLastClick(event) {
        const imageRange = $('#imageRange');
        const offset = parseInt(imageRange.children().last().val());
        imageRange.val(offset);
        this.requestImages();
        this.refreshUIState();
    }

    enableElement(selector, enabled) {
        const button = $(selector);
        if (enabled) {
            button.removeAttr('disabled');
        } else {
            button.attr('disabled', 'disabled');
        }
    }

    refreshUIState() {
        const isFirst = this.isFirstImageRange;
        const isLast = this.isLastImageRange;

        this.enableElement('#first', !isFirst);
        this.enableElement('#last', !isLast);
        this.enableElement('#prev', !isFirst);
        this.enableElement('#next', !isLast);
        this.enableElement('#imageRange', !isFirst && !isLast);

        const anySelected = !_.isEqual(this.selection, this.selectNone());
        const allSelected = _.isEqual(this.selection, this.selectAll());

        this.enableElement('#selectAll', !allSelected);
        this.enableElement('#selectNone', anySelected);
        this.enableElement('#downloadSelected', anySelected);
    }

    onCheckboxClick(event) {
        const index = parseInt(event.target.attributes.index.value);
        if (event.target.checked) {
            this.selection[index] = event.target.checked;
        } else {
            delete this.selection[index];
        }
        this.refreshUIState();
    }

    selectAll() {
        const totalImages = this.imageStore.totalImages;
        const selection = {};

        for (let index = 0; index < totalImages; index++) {
            selection[index] = true;
        }

        return selection;
    }

    selectNone() {
        return [];
    }

    selectionInvert(currentSelection) {
        const totalImages = this.imageStore.totalImages;
        const selection = {};

        for (let index = 0; index < totalImages; index++) {
            selection[index] = !currentSelection[index];
        }

        return selection;
    }

    refreshUISelection() {
        const checkboxes = $('input.checkbox').toArray();
        checkboxes.forEach(checkbox => {
            const index = parseInt(checkbox.attributes.index.value);
            const isSelected = this.selection[index];
            checkbox.checked = isSelected;
        });
        this.refreshUIState();
    }

    onSelectAllClick() {
        this.selection = this.selectAll();
        this.refreshUISelection();
    }

    onSelectNoneClick() {
        this.selection = this.selectNone();
        this.refreshUISelection();
    }

    onSelectInvertClick() {
        this.selection = this.selectionInvert(this.selection);
        this.refreshUISelection();
    }

    onDownloadAllClick() {
        this.downloadImages(this.selectAll());
    }

    onDownloadSelectedClick() {
        this.downloadImages(this.selection);
    }

    downloadImages(selection) {
        const modal = new Modal('#downloadModal');
        const imageDownloader = new ImageDownloader();

        imageDownloader.prepareDownload(selection, (error, result) => {
            if (error) {
                // TODO: Handle the error.
                return;
            }

            imageDownloader.waitForPreparationToComplete(
                (progress) => {
                    modal.progress = progress;
                },
                (error, results) => {
                    if (error) {
                        // TODO: Handle the error.
                        return;
                    }

                    modal.progress = 100;

                    imageDownloader.getDownload(results.downloadUrl);

                    modal.close(500);
                }
            );
        });

        // TODO:
        // - Hit end-point to wait for download to complete
        //   - Update percentage complete...
        // - Hit end-point to download the file
        // - Dismiss the modal.
    }
}

let gallery;

export function pageLoaded() {
    gallery = new Gallery();
}
