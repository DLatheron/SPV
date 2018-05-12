/* globals window */
'use strict';

export class ImageDownloader {
    constructor() {
        this.intervalId = null;
    }

    prepareDownload(selection, callback) {
        if (selection === undefined) {
            // TODO: Download everything...
        } else {
            // TODO: Download just the selected media.
        }

        // setTimeout(() => {
        //     callback(null, {
        //         progressUrl: '/downloadProgress/1234'
        //     });
        // }, 1000);
        const url = `/prepareImagesForDownload`;

        $.ajax({
            type: 'POST',
            url,
            data: JSON.stringify(selection),
            success: (results) => {
                callback(null, results);
            },
            error: (jqXHR, textStatus, errorThrown) => {
                callback(`Failed to download file(s) from the server: ${errorThrown}`);
            }
        });
    }

    waitForPreparationToComplete(downloadId, progressCallback, completionCallback) {
        const url = `/downloadProgress/${downloadId}`;

        let percentage = 0;

        progressCallback(percentage);

        this.intervalId = setInterval(() => {
            $.ajax({
                type: 'GET',
                url,
                success: ({ status, downloadUrl, percentage }) => {
                    percentage = Math.max(Math.min(percentage, 100), 0);
                    progressCallback(percentage);

                    if (status === 'done') {
                        if (this.intervalId) {
                            clearInterval(this.intervalId);
                            this.intervalId = null;

                            completionCallback(null, {
                                downloadUrl
                            });
                        }
                    }
                },
                error: (jqXHR, textStatus, errorThrown) => {
                    if (this.intervalId) {
                        clearInterval(this.intervalId);
                        this.intervalId = null;

                        completionCallback(`Failed to download file(s) from the server: ${errorThrown}`);
                    }
                }
            });
        }, 1000);
    }

    getDownload(downloadUrl) {
        const fullUrl = `${window.location.origin}${downloadUrl}`;
        window.location = fullUrl;
        // window.open(fullUrl, '_blank');
    }
}
