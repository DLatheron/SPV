'use strict';
/* globals console, $, _ */

import { ImageStore } from '/src/ImageStore.js';

const imageStore = new ImageStore();

const quantities = [
    { value: 1 },
    { value: 2 },
    { value: 3 },
    { value: 4 },
    { value: 5 },
    { value: 10, default: true },
    { value: 20 },
    { value: 'all' }
];
const sortByItems = [
    { value: 'name', default: true },
    { value: 'date' },
    { value: 'size' },
    { value: 'rating' }
];
const directionItems = [
    { value: 'ascending', default: true },
    { value: 'descending' }
];
const thumbnailSizes = [
    { value:  64, text: 'tiny' },
    { value: 128, text: 'small', default: true },
    { value: 256, text: 'medium' },
    { value: 512, text: 'large' },
];
const displayModes = [
    { value: 'aspect' },
    { value: 'crop', default: true }
];
let imageRanges = [];

function getSortBy() {
    return $('#sortBy').first().val();
}

function getDirection() {
    return $('#direction').first().val();
}

function getQuantity() {
    let quantity = $('#quantity').first().val();
    if (quantity === 'all') {
        return imageStore.totalImages;
    } else {
        return parseInt(quantity);
    }
}

function getImageRange() {
    return parseInt($('#imageRange').first().val() || 0);
}

function getSize() {
    return parseInt($('#size').first().val());
}

function getDisplayMode() {
    return $('#displayMode').first().val();
}

function onSortByChange(event) {
    console.log(`Sort By changed to ${event.target.value}`);
    requestImages();
}

function onDirectionChange(event) {
    console.log(`Direction changed to ${event.target.value}`);
    requestImages();
}

function onQuantityChange(event, previousFirstImage) {
    console.log(`Quantity changed to ${event.target.value}`);
    updateImageRanges(previousFirstImage, getQuantity());
    requestImages();
}

function onImageRangeChange(event) {
    console.log(`Image range changed to ${event.target.value}`);
    requestImages();
}

function onSizeChange(event) {
    console.log(`Thumbnail size changed to ${event.target.value}`);
    refreshImages();
}

function onDisplayModeChamge(event) {
    console.log(`Display mode changed to ${event.target.value}`);
    refreshImages();
}

function makeOption({ value, text }) {
    text = text || value;
    return `<option value='${value}'>${text}</option>`;
}

function formatRange(startImage, endImage, maxDigits) {
    const nbspPadding = ' '; // <-- Alt-Enter for nbsp.
    const first = `${startImage + 1}`.padStart(maxDigits, nbspPadding);
    if (startImage >= (endImage - 1)) {
        return first;
    } else {
        const second = `${endImage}`.padEnd(maxDigits, nbspPadding);

        return `${first} - ${second}`;
    }
}

function updateImageRanges(offset, quantity) {
    const batchSize = getQuantity();
    const maxDigits = imageStore.totalImages.length;
    imageRanges = [];

    for (
        let startImage = 0;
        startImage < imageStore.totalImages;
        startImage += batchSize
    ) {
        const endImage = Math.min(startImage + batchSize, imageStore.totalImages);
        const imageRange = formatRange(startImage, endImage, maxDigits);
        imageRanges.push({ value: startImage, text: imageRange });

        console.log(`${startImage + 1} => ${imageRange}`);
    }

    populateSelectBox('#imageRange', imageRanges);

    selectImageRangeForOffset(offset, quantity);
}

function selectImageRangeForOffset(offset, quantity) {
    if (offset === undefined) {
        return;
    }

    const rangeToSelect = imageRanges.find(range => {
        const startImage = range.value;
        const endImage = Math.min(startImage + quantity, imageStore.totalImages + 1);
        return (offset >= startImage && offset < endImage);
    });

    if (rangeToSelect) {
        const startImage = rangeToSelect.value;
        const endImage = Math.min(startImage + quantity, imageStore.totalImages + 1);
        $('#imageRange').val(startImage);
        console.log(`Offset ${offset} contained in range ${startImage} - ${endImage - 1}`);
    }
}

function requestImages() {
    const sortBy = getSortBy();
    const direction = getDirection();
    const quantity = getQuantity();
    const offset = getImageRange();

    imageStore.getImages(sortBy, direction, offset, quantity, (error) => {
        refreshImages();
    });
}

function refreshImages() {
    const dimension = getSize();
    const displayMode = getDisplayMode();

    imageStore.resizeImagesTo(dimension, dimension, (displayMode === 'aspect'));

    const galleryDiv = $('#gallery').first();
    galleryDiv.empty();
    imageStore.addToElement(galleryDiv);
}

function populateSelectBox(selector, options) {
    const selectBox = $(selector);
    selectBox.empty();
    options.forEach(item => selectBox.append(makeOption(item)));
    if (options.length === 1) {
        selectBox.attr('disabled', 'disabled');
    } else {
        selectBox.removeAttr('disabled');
    }

    const defaultOption = options.find(item => item.default);
    if (defaultOption) {
        selectBox.val(defaultOption.value);
    }
}

let previousQuantity;
let previousFirstImage;

export function pageLoaded() {
    console.log('pageLoaded');

    $('#sortBy').change(onSortByChange);
    $('#direction').change(onDirectionChange);
    $('#quantity')
        .on('focus', function() {
            previousQuantity = parseInt(this.value);
        })
        .change(function(event) {
            onQuantityChange(event, previousFirstImage);
            previousQuantity = parseInt(this.value);
        });

    $('#imageRange')
        .on('focus', function() {
            previousFirstImage = parseInt(this.value);
        })
        .change(function(event) {
            onImageRangeChange(event);
            previousFirstImage = parseInt(this.value);
        });
    $('#size').change(onSizeChange);
    $('#displayMode').change(onDisplayModeChamge);

    populateSelectBox('#sortBy', sortByItems);
    populateSelectBox('#direction', directionItems);
    populateSelectBox('#quantity', quantities);
    populateSelectBox('#size', thumbnailSizes);
    populateSelectBox('#displayMode', displayModes);

    // $('#sortBy').val('name');
    // $('#direction').val('ascending');
    // $('#quantity').val(10);
    // $('#size').val(128);

    imageStore.getImageTotals((error) => {
        updateImageRanges(0, imageStore.totalImages);

        requestImages();
    });
}
