export class ImageDownloader {
    constructor() {

    }

    prepareDownload(selection, callback) {
        setTimeout(() => {
            callback(null, {
                progressUrl: '/downloadProgress/1234'
            });
        }, 1000);
        // const url = `/downloadImages`;

        // $.ajax({
        //     type: 'POST',
        //     url,
        //     data: selection,
        //     success: (results) => {

        //     },
        //     error: (jqXHR, textStatus, errorThrown) => {
        //         alert(`Failed to download file(s) from the server: ${errorThrown}`);
        //         modal.close();
        //     }
        // });
    }

    waitForPreparationToComplete(progressCallback, completionCallback) {
        let percentage = 0;

        progressCallback(percentage);

        setInterval(() => {
            percentage = Math.min(percentage + 10, 100);
            progressCallback(percentage);

            if (percentage === 100) {
                completionCallback(null, {
                    downloadUrl: '/downloads/1234/temp.zip'
                });
            }
        }, 1000);
    }

    getDownload() {

    }
}