(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
  window.Uppy = {}
  Uppy.Core = require("@uppy/core")
  Uppy.AwsS3 = require("@uppy/aws-s3")
  Uppy.XHRUpload = require("@uppy/xhr-upload")
  Uppy.ThumbnailGenerator = require("@uppy/thumbnail-generator")

  },{"@uppy/aws-s3":4,"@uppy/core":14,"@uppy/thumbnail-generator":18,"@uppy/xhr-upload":40}],2:[function(require,module,exports){
  // Adapted from https://github.com/Flet/prettier-bytes/
  // Changing 1000 bytes to 1024, so we can keep uppercase KB vs kB
  // ISC License (c) Dan Flettre https://github.com/Flet/prettier-bytes/blob/master/LICENSE
  module.exports = function prettierBytes (num) {
    if (typeof num !== 'number' || isNaN(num)) {
      throw new TypeError('Expected a number, got ' + typeof num)
    }

    var neg = num < 0
    var units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']

    if (neg) {
      num = -num
    }

    if (num < 1) {
      return (neg ? '-' : '') + num + ' B'
    }

    var exponent = Math.min(Math.floor(Math.log(num) / Math.log(1024)), units.length - 1)
    num = Number(num / Math.pow(1024, exponent))
    var unit = units[exponent]

    if (num >= 10 || num % 1 === 0) {
      // Do not show decimals when the number is two-digit, or if the number has no
      // decimal component.
      return (neg ? '-' : '') + num.toFixed(0) + ' ' + unit
    } else {
      return (neg ? '-' : '') + num.toFixed(1) + ' ' + unit
    }
  }

  },{}],3:[function(require,module,exports){
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  var cuid = require('cuid');

  var _require = require('@uppy/companion-client'),
      Provider = _require.Provider,
      RequestClient = _require.RequestClient,
      Socket = _require.Socket;

  var emitSocketProgress = require('@uppy/utils/lib/emitSocketProgress');

  var getSocketHost = require('@uppy/utils/lib/getSocketHost');

  var EventTracker = require('@uppy/utils/lib/EventTracker');

  var ProgressTimeout = require('@uppy/utils/lib/ProgressTimeout');

  var NetworkError = require('@uppy/utils/lib/NetworkError');

  var isNetworkError = require('@uppy/utils/lib/isNetworkError'); // See XHRUpload


  function buildResponseError(xhr, error) {
    // No error message
    if (!error) error = new Error('Upload error'); // Got an error message string

    if (typeof error === 'string') error = new Error(error); // Got something else

    if (!(error instanceof Error)) {
      error = _extends(new Error('Upload error'), {
        data: error
      });
    }

    if (isNetworkError(xhr)) {
      error = new NetworkError(error, xhr);
      return error;
    }

    error.request = xhr;
    return error;
  } // See XHRUpload


  function setTypeInBlob(file) {
    var dataWithUpdatedType = file.data.slice(0, file.data.size, file.meta.type);
    return dataWithUpdatedType;
  }

  module.exports = /*#__PURE__*/function () {
    function MiniXHRUpload(uppy, opts) {
      this.uppy = uppy;
      this.opts = _extends({
        validateStatus: function validateStatus(status, responseText, response) {
          return status >= 200 && status < 300;
        }
      }, opts);
      this.requests = opts.__queue;
      this.uploaderEvents = Object.create(null);
      this.i18n = opts.i18n;
    }

    var _proto = MiniXHRUpload.prototype;

    _proto._getOptions = function _getOptions(file) {
      var uppy = this.uppy;
      var overrides = uppy.getState().xhrUpload;

      var opts = _extends({}, this.opts, overrides || {}, file.xhrUpload || {}, {
        headers: {}
      });

      _extends(opts.headers, this.opts.headers);

      if (overrides) {
        _extends(opts.headers, overrides.headers);
      }

      if (file.xhrUpload) {
        _extends(opts.headers, file.xhrUpload.headers);
      }

      return opts;
    };

    _proto.uploadFile = function uploadFile(id, current, total) {
      var file = this.uppy.getFile(id);

      if (file.error) {
        throw new Error(file.error);
      } else if (file.isRemote) {
        return this._uploadRemoteFile(file, current, total);
      }

      return this._uploadLocalFile(file, current, total);
    };

    _proto._addMetadata = function _addMetadata(formData, meta, opts) {
      var metaFields = Array.isArray(opts.metaFields) ? opts.metaFields // Send along all fields by default.
      : Object.keys(meta);
      metaFields.forEach(function (item) {
        formData.append(item, meta[item]);
      });
    };

    _proto._createFormDataUpload = function _createFormDataUpload(file, opts) {
      var formPost = new FormData();

      this._addMetadata(formPost, file.meta, opts);

      var dataWithUpdatedType = setTypeInBlob(file);

      if (file.name) {
        formPost.append(opts.fieldName, dataWithUpdatedType, file.meta.name);
      } else {
        formPost.append(opts.fieldName, dataWithUpdatedType);
      }

      return formPost;
    };

    _proto._createBareUpload = function _createBareUpload(file, opts) {
      return file.data;
    };

    _proto._onFileRemoved = function _onFileRemoved(fileID, cb) {
      this.uploaderEvents[fileID].on('file-removed', function (file) {
        if (fileID === file.id) cb(file.id);
      });
    };

    _proto._onRetry = function _onRetry(fileID, cb) {
      this.uploaderEvents[fileID].on('upload-retry', function (targetFileID) {
        if (fileID === targetFileID) {
          cb();
        }
      });
    };

    _proto._onRetryAll = function _onRetryAll(fileID, cb) {
      var _this = this;

      this.uploaderEvents[fileID].on('retry-all', function (filesToRetry) {
        if (!_this.uppy.getFile(fileID)) return;
        cb();
      });
    };

    _proto._onCancelAll = function _onCancelAll(fileID, cb) {
      var _this2 = this;

      this.uploaderEvents[fileID].on('cancel-all', function () {
        if (!_this2.uppy.getFile(fileID)) return;
        cb();
      });
    };

    _proto._uploadLocalFile = function _uploadLocalFile(file, current, total) {
      var _this3 = this;

      var opts = this._getOptions(file);

      this.uppy.log("uploading " + current + " of " + total);
      return new Promise(function (resolve, reject) {
        // This is done in index.js in the S3 plugin.
        // this.uppy.emit('upload-started', file)
        var data = opts.formData ? _this3._createFormDataUpload(file, opts) : _this3._createBareUpload(file, opts);
        var xhr = new XMLHttpRequest();
        _this3.uploaderEvents[file.id] = new EventTracker(_this3.uppy);
        var timer = new ProgressTimeout(opts.timeout, function () {
          xhr.abort();
          queuedRequest.done();
          var error = new Error(_this3.i18n('timedOut', {
            seconds: Math.ceil(opts.timeout / 1000)
          }));

          _this3.uppy.emit('upload-error', file, error);

          reject(error);
        });
        var id = cuid();
        xhr.upload.addEventListener('loadstart', function (ev) {
          _this3.uppy.log("[AwsS3/XHRUpload] " + id + " started");
        });
        xhr.upload.addEventListener('progress', function (ev) {
          _this3.uppy.log("[AwsS3/XHRUpload] " + id + " progress: " + ev.loaded + " / " + ev.total); // Begin checking for timeouts when progress starts, instead of loading,
          // to avoid timing out requests on browser concurrency queue


          timer.progress();

          if (ev.lengthComputable) {
            _this3.uppy.emit('upload-progress', file, {
              uploader: _this3,
              bytesUploaded: ev.loaded,
              bytesTotal: ev.total
            });
          }
        });
        xhr.addEventListener('load', function (ev) {
          _this3.uppy.log("[AwsS3/XHRUpload] " + id + " finished");

          timer.done();
          queuedRequest.done();

          if (_this3.uploaderEvents[file.id]) {
            _this3.uploaderEvents[file.id].remove();

            _this3.uploaderEvents[file.id] = null;
          }

          if (opts.validateStatus(ev.target.status, xhr.responseText, xhr)) {
            var body = opts.getResponseData(xhr.responseText, xhr);
            var uploadURL = body[opts.responseUrlFieldName];
            var uploadResp = {
              status: ev.target.status,
              body: body,
              uploadURL: uploadURL
            };

            _this3.uppy.emit('upload-success', file, uploadResp);

            if (uploadURL) {
              _this3.uppy.log("Download " + file.name + " from " + uploadURL);
            }

            return resolve(file);
          } else {
            var _body = opts.getResponseData(xhr.responseText, xhr);

            var error = buildResponseError(xhr, opts.getResponseError(xhr.responseText, xhr));
            var response = {
              status: ev.target.status,
              body: _body
            };

            _this3.uppy.emit('upload-error', file, error, response);

            return reject(error);
          }
        });
        xhr.addEventListener('error', function (ev) {
          _this3.uppy.log("[AwsS3/XHRUpload] " + id + " errored");

          timer.done();
          queuedRequest.done();

          if (_this3.uploaderEvents[file.id]) {
            _this3.uploaderEvents[file.id].remove();

            _this3.uploaderEvents[file.id] = null;
          }

          var error = buildResponseError(xhr, opts.getResponseError(xhr.responseText, xhr));

          _this3.uppy.emit('upload-error', file, error);

          return reject(error);
        });
        xhr.open(opts.method.toUpperCase(), opts.endpoint, true); // IE10 does not allow setting `withCredentials` and `responseType`
        // before `open()` is called.

        xhr.withCredentials = opts.withCredentials;

        if (opts.responseType !== '') {
          xhr.responseType = opts.responseType;
        }

        Object.keys(opts.headers).forEach(function (header) {
          xhr.setRequestHeader(header, opts.headers[header]);
        });

        var queuedRequest = _this3.requests.run(function () {
          xhr.send(data);
          return function () {
            timer.done();
            xhr.abort();
          };
        }, {
          priority: 1
        });

        _this3._onFileRemoved(file.id, function () {
          queuedRequest.abort();
          reject(new Error('File removed'));
        });

        _this3._onCancelAll(file.id, function () {
          queuedRequest.abort();
          reject(new Error('Upload cancelled'));
        });
      });
    };

    _proto._uploadRemoteFile = function _uploadRemoteFile(file, current, total) {
      var _this4 = this;

      var opts = this._getOptions(file);

      return new Promise(function (resolve, reject) {
        // This is done in index.js in the S3 plugin.
        // this.uppy.emit('upload-started', file)
        var fields = {};
        var metaFields = Array.isArray(opts.metaFields) ? opts.metaFields // Send along all fields by default.
        : Object.keys(file.meta);
        metaFields.forEach(function (name) {
          fields[name] = file.meta[name];
        });
        var Client = file.remote.providerOptions.provider ? Provider : RequestClient;
        var client = new Client(_this4.uppy, file.remote.providerOptions);
        client.post(file.remote.url, _extends({}, file.remote.body, {
          endpoint: opts.endpoint,
          size: file.data.size,
          fieldname: opts.fieldName,
          metadata: fields,
          httpMethod: opts.method,
          useFormData: opts.formData,
          headers: opts.headers
        })).then(function (res) {
          var token = res.token;
          var host = getSocketHost(file.remote.companionUrl);
          var socket = new Socket({
            target: host + "/api/" + token,
            autoOpen: false
          });
          _this4.uploaderEvents[file.id] = new EventTracker(_this4.uppy);

          _this4._onFileRemoved(file.id, function () {
            socket.send('pause', {});
            queuedRequest.abort();
            resolve("upload " + file.id + " was removed");
          });

          _this4._onCancelAll(file.id, function () {
            socket.send('pause', {});
            queuedRequest.abort();
            resolve("upload " + file.id + " was canceled");
          });

          _this4._onRetry(file.id, function () {
            socket.send('pause', {});
            socket.send('resume', {});
          });

          _this4._onRetryAll(file.id, function () {
            socket.send('pause', {});
            socket.send('resume', {});
          });

          socket.on('progress', function (progressData) {
            return emitSocketProgress(_this4, progressData, file);
          });
          socket.on('success', function (data) {
            var body = opts.getResponseData(data.response.responseText, data.response);
            var uploadURL = body[opts.responseUrlFieldName];
            var uploadResp = {
              status: data.response.status,
              body: body,
              uploadURL: uploadURL
            };

            _this4.uppy.emit('upload-success', file, uploadResp);

            queuedRequest.done();

            if (_this4.uploaderEvents[file.id]) {
              _this4.uploaderEvents[file.id].remove();

              _this4.uploaderEvents[file.id] = null;
            }

            return resolve();
          });
          socket.on('error', function (errData) {
            var resp = errData.response;
            var error = resp ? opts.getResponseError(resp.responseText, resp) : _extends(new Error(errData.error.message), {
              cause: errData.error
            });

            _this4.uppy.emit('upload-error', file, error);

            queuedRequest.done();

            if (_this4.uploaderEvents[file.id]) {
              _this4.uploaderEvents[file.id].remove();

              _this4.uploaderEvents[file.id] = null;
            }

            reject(error);
          });

          var queuedRequest = _this4.requests.run(function () {
            socket.open();

            if (file.isPaused) {
              socket.send('pause', {});
            }

            return function () {
              return socket.close();
            };
          });
        }).catch(function (err) {
          _this4.uppy.emit('upload-error', file, err);

          reject(err);
        });
      });
    };

    return MiniXHRUpload;
  }();
  },{"@uppy/companion-client":11,"@uppy/utils/lib/EventTracker":19,"@uppy/utils/lib/NetworkError":20,"@uppy/utils/lib/ProgressTimeout":21,"@uppy/utils/lib/emitSocketProgress":25,"@uppy/utils/lib/getSocketHost":31,"@uppy/utils/lib/isNetworkError":35,"cuid":41}],4:[function(require,module,exports){
  var _class, _temp;

  function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  /**
   * This plugin is currently a A Big Hack™! The core reason for that is how this plugin
   * interacts with Uppy's current pipeline design. The pipeline can handle files in steps,
   * including preprocessing, uploading, and postprocessing steps. This plugin initially
   * was designed to do its work in a preprocessing step, and let XHRUpload deal with the
   * actual file upload as an uploading step. However, Uppy runs steps on all files at once,
   * sequentially: first, all files go through a preprocessing step, then, once they are all
   * done, they go through the uploading step.
   *
   * For S3, this causes severely broken behaviour when users upload many files. The
   * preprocessing step will request S3 upload URLs that are valid for a short time only,
   * but it has to do this for _all_ files, which can take a long time if there are hundreds
   * or even thousands of files. By the time the uploader step starts, the first URLs may
   * already have expired. If not, the uploading might take such a long time that later URLs
   * will expire before some files can be uploaded.
   *
   * The long-term solution to this problem is to change the upload pipeline so that files
   * can be sent to the next step individually. That requires a breakig change, so it is
   * planned for Uppy v2.
   *
   * In the mean time, this plugin is stuck with a hackier approach: the necessary parts
   * of the XHRUpload implementation were copied into this plugin, as the MiniXHRUpload
   * class, and this plugin calls into it immediately once it receives an upload URL.
   * This isn't as nicely modular as we'd like and requires us to maintain two copies of
   * the XHRUpload code, but at least it's not horrifically broken :)
   */
  // If global `URL` constructor is available, use it
  var URL_ = typeof URL === 'function' ? URL : require('url-parse');

  var _require = require('@uppy/core'),
      Plugin = _require.Plugin;

  var Translator = require('@uppy/utils/lib/Translator');

  var RateLimitedQueue = require('@uppy/utils/lib/RateLimitedQueue');

  var settle = require('@uppy/utils/lib/settle');

  var hasProperty = require('@uppy/utils/lib/hasProperty');

  var _require2 = require('@uppy/companion-client'),
      RequestClient = _require2.RequestClient;

  var qsStringify = require('qs-stringify');

  var MiniXHRUpload = require('./MiniXHRUpload');

  var isXml = require('./isXml');

  function resolveUrl(origin, link) {
    return origin ? new URL_(link, origin).toString() : new URL_(link).toString();
  }
  /**
   * Get the contents of a named tag in an XML source string.
   *
   * @param {string} source - The XML source string.
   * @param {string} tagName - The name of the tag.
   * @returns {string} The contents of the tag, or the empty string if the tag does not exist.
   */


  function getXmlValue(source, tagName) {
    var start = source.indexOf("<" + tagName + ">");
    var end = source.indexOf("</" + tagName + ">", start);
    return start !== -1 && end !== -1 ? source.slice(start + tagName.length + 2, end) : '';
  }

  function assertServerError(res) {
    if (res && res.error) {
      var error = new Error(res.message);

      _extends(error, res.error);

      throw error;
    }

    return res;
  } // warning deduplication flag: see `getResponseData()` XHRUpload option definition


  var warnedSuccessActionStatus = false;
  module.exports = (_temp = _class = /*#__PURE__*/function (_Plugin) {
    _inheritsLoose(AwsS3, _Plugin);

    function AwsS3(uppy, opts) {
      var _this;

      _this = _Plugin.call(this, uppy, opts) || this;
      _this.type = 'uploader';
      _this.id = _this.opts.id || 'AwsS3';
      _this.title = 'AWS S3';
      _this.defaultLocale = {
        strings: {
          timedOut: 'Upload stalled for %{seconds} seconds, aborting.'
        }
      };
      var defaultOptions = {
        timeout: 30 * 1000,
        limit: 0,
        metaFields: [],
        // have to opt in
        getUploadParameters: _this.getUploadParameters.bind(_assertThisInitialized(_this))
      };
      _this.opts = _extends({}, defaultOptions, opts);

      _this.i18nInit();

      _this.client = new RequestClient(uppy, opts);
      _this.handleUpload = _this.handleUpload.bind(_assertThisInitialized(_this));
      _this.requests = new RateLimitedQueue(_this.opts.limit);
      return _this;
    }

    var _proto = AwsS3.prototype;

    _proto.setOptions = function setOptions(newOpts) {
      _Plugin.prototype.setOptions.call(this, newOpts);

      this.i18nInit();
    };

    _proto.i18nInit = function i18nInit() {
      this.translator = new Translator([this.defaultLocale, this.uppy.locale, this.opts.locale]);
      this.i18n = this.translator.translate.bind(this.translator);
      this.setPluginState(); // so that UI re-renders and we see the updated locale
    };

    _proto.getUploadParameters = function getUploadParameters(file) {
      if (!this.opts.companionUrl) {
        throw new Error('Expected a `companionUrl` option containing a Companion address.');
      }

      var filename = file.meta.name;
      var type = file.meta.type;
      var metadata = {};
      this.opts.metaFields.forEach(function (key) {
        if (file.meta[key] != null) {
          metadata[key] = file.meta[key].toString();
        }
      });
      var query = qsStringify({
        filename: filename,
        type: type,
        metadata: metadata
      });
      return this.client.get("s3/params?" + query).then(assertServerError);
    };

    _proto.validateParameters = function validateParameters(file, params) {
      var valid = typeof params === 'object' && params && typeof params.url === 'string' && (typeof params.fields === 'object' || params.fields == null);

      if (!valid) {
        var err = new TypeError("AwsS3: got incorrect result from 'getUploadParameters()' for file '" + file.name + "', expected an object '{ url, method, fields, headers }' but got '" + JSON.stringify(params) + "' instead.\nSee https://uppy.io/docs/aws-s3/#getUploadParameters-file for more on the expected format.");
        console.error(err);
        throw err;
      }

      var methodIsValid = params.method == null || /^(put|post)$/i.test(params.method);

      if (!methodIsValid) {
        var _err = new TypeError("AwsS3: got incorrect method from 'getUploadParameters()' for file '" + file.name + "', expected  'put' or 'post' but got '" + params.method + "' instead.\nSee https://uppy.io/docs/aws-s3/#getUploadParameters-file for more on the expected format.");

        console.error(_err);
        throw _err;
      }
    };

    _proto.handleUpload = function handleUpload(fileIDs) {
      var _this2 = this;

      /**
       * keep track of `getUploadParameters()` responses
       * so we can cancel the calls individually using just a file ID
       *
       * @type {object.<string, Promise>}
       */
      var paramsPromises = Object.create(null);

      function onremove(file) {
        var id = file.id;

        if (hasProperty(paramsPromises, id)) {
          paramsPromises[id].abort();
        }
      }

      this.uppy.on('file-removed', onremove);
      fileIDs.forEach(function (id) {
        var file = _this2.uppy.getFile(id);

        _this2.uppy.emit('upload-started', file);
      });
      var getUploadParameters = this.requests.wrapPromiseFunction(function (file) {
        return _this2.opts.getUploadParameters(file);
      });
      var numberOfFiles = fileIDs.length;
      return settle(fileIDs.map(function (id, index) {
        paramsPromises[id] = getUploadParameters(_this2.uppy.getFile(id));
        return paramsPromises[id].then(function (params) {
          delete paramsPromises[id];

          var file = _this2.uppy.getFile(id);

          _this2.validateParameters(file, params);

          var _params$method = params.method,
              method = _params$method === void 0 ? 'post' : _params$method,
              url = params.url,
              fields = params.fields,
              headers = params.headers;
          var xhrOpts = {
            method: method,
            formData: method.toLowerCase() === 'post',
            endpoint: url,
            metaFields: fields ? Object.keys(fields) : []
          };

          if (headers) {
            xhrOpts.headers = headers;
          }

          _this2.uppy.setFileState(file.id, {
            meta: _extends({}, file.meta, fields),
            xhrUpload: xhrOpts
          });

          return _this2._uploader.uploadFile(file.id, index, numberOfFiles);
        }).catch(function (error) {
          delete paramsPromises[id];

          var file = _this2.uppy.getFile(id);

          _this2.uppy.emit('upload-error', file, error);
        });
      })).then(function (settled) {
        // cleanup.
        _this2.uppy.off('file-removed', onremove);

        return settled;
      });
    };

    _proto.install = function install() {
      var uppy = this.uppy;
      this.uppy.addUploader(this.handleUpload); // Get the response data from a successful XMLHttpRequest instance.
      // `content` is the S3 response as a string.
      // `xhr` is the XMLHttpRequest instance.

      function defaultGetResponseData(content, xhr) {
        var opts = this; // If no response, we've hopefully done a PUT request to the file
        // in the bucket on its full URL.

        if (!isXml(content, xhr)) {
          if (opts.method.toUpperCase() === 'POST') {
            if (!warnedSuccessActionStatus) {
              uppy.log('[AwsS3] No response data found, make sure to set the success_action_status AWS SDK option to 201. See https://uppy.io/docs/aws-s3/#POST-Uploads', 'warning');
              warnedSuccessActionStatus = true;
            } // The responseURL won't contain the object key. Give up.


            return {
              location: null
            };
          } // responseURL is not available in older browsers.


          if (!xhr.responseURL) {
            return {
              location: null
            };
          } // Trim the query string because it's going to be a bunch of presign
          // parameters for a PUT request—doing a GET request with those will
          // always result in an error


          return {
            location: xhr.responseURL.replace(/\?.*$/, '')
          };
        }

        return {
          // Some S3 alternatives do not reply with an absolute URL.
          // Eg DigitalOcean Spaces uses /$bucketName/xyz
          location: resolveUrl(xhr.responseURL, getXmlValue(content, 'Location')),
          bucket: getXmlValue(content, 'Bucket'),
          key: getXmlValue(content, 'Key'),
          etag: getXmlValue(content, 'ETag')
        };
      } // Get the error data from a failed XMLHttpRequest instance.
      // `content` is the S3 response as a string.
      // `xhr` is the XMLHttpRequest instance.


      function defaultGetResponseError(content, xhr) {
        // If no response, we don't have a specific error message, use the default.
        if (!isXml(content, xhr)) {
          return;
        }

        var error = getXmlValue(content, 'Message');
        return new Error(error);
      }

      var xhrOptions = {
        fieldName: 'file',
        responseUrlFieldName: 'location',
        timeout: this.opts.timeout,
        // Share the rate limiting queue with XHRUpload.
        __queue: this.requests,
        responseType: 'text',
        getResponseData: this.opts.getResponseData || defaultGetResponseData,
        getResponseError: defaultGetResponseError
      }; // Only for MiniXHRUpload, remove once we can depend on XHRUpload directly again

      xhrOptions.i18n = this.i18n; // Revert to `this.uppy.use(XHRUpload)` once the big comment block at the top of
      // this file is solved

      this._uploader = new MiniXHRUpload(this.uppy, xhrOptions);
    };

    _proto.uninstall = function uninstall() {
      this.uppy.removePreProcessor(this.handleUpload);
    };

    return AwsS3;
  }(Plugin), _class.VERSION = "1.7.3", _temp);
  },{"./MiniXHRUpload":3,"./isXml":5,"@uppy/companion-client":11,"@uppy/core":14,"@uppy/utils/lib/RateLimitedQueue":22,"@uppy/utils/lib/Translator":23,"@uppy/utils/lib/hasProperty":33,"@uppy/utils/lib/settle":39,"qs-stringify":51,"url-parse":54}],5:[function(require,module,exports){
  /**
   * Remove parameters like `charset=utf-8` from the end of a mime type string.
   *
   * @param {string} mimeType - The mime type string that may have optional parameters.
   * @returns {string} The "base" mime type, i.e. only 'category/type'.
   */
  function removeMimeParameters(mimeType) {
    return mimeType.replace(/;.*$/, '');
  }
  /**
   * Check if a response contains XML based on the response object and its text content.
   *
   * @param {string} content - The text body of the response.
   * @param {object|XMLHttpRequest} xhr - The XHR object or response object from Companion.
   * @returns {bool} Whether the content is (probably) XML.
   */


  function isXml(content, xhr) {
    var rawContentType = xhr.headers ? xhr.headers['content-type'] : xhr.getResponseHeader('Content-Type');

    if (typeof rawContentType === 'string') {
      var contentType = removeMimeParameters(rawContentType).toLowerCase();

      if (contentType === 'application/xml' || contentType === 'text/xml') {
        return true;
      } // GCS uses text/html for some reason
      // https://github.com/transloadit/uppy/issues/896


      if (contentType === 'text/html' && /^<\?xml /.test(content)) {
        return true;
      }
    }

    return false;
  }

  module.exports = isXml;
  },{}],6:[function(require,module,exports){
  'use strict';

  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

  function _wrapNativeSuper(Class) { var _cache = typeof Map === "function" ? new Map() : undefined; _wrapNativeSuper = function _wrapNativeSuper(Class) { if (Class === null || !_isNativeFunction(Class)) return Class; if (typeof Class !== "function") { throw new TypeError("Super expression must either be null or a function"); } if (typeof _cache !== "undefined") { if (_cache.has(Class)) return _cache.get(Class); _cache.set(Class, Wrapper); } function Wrapper() { return _construct(Class, arguments, _getPrototypeOf(this).constructor); } Wrapper.prototype = Object.create(Class.prototype, { constructor: { value: Wrapper, enumerable: false, writable: true, configurable: true } }); return _setPrototypeOf(Wrapper, Class); }; return _wrapNativeSuper(Class); }

  function _construct(Parent, args, Class) { if (_isNativeReflectConstruct()) { _construct = Reflect.construct; } else { _construct = function _construct(Parent, args, Class) { var a = [null]; a.push.apply(a, args); var Constructor = Function.bind.apply(Parent, a); var instance = new Constructor(); if (Class) _setPrototypeOf(instance, Class.prototype); return instance; }; } return _construct.apply(null, arguments); }

  function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }

  function _isNativeFunction(fn) { return Function.toString.call(fn).indexOf("[native code]") !== -1; }

  function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }

  function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

  var AuthError = /*#__PURE__*/function (_Error) {
    _inheritsLoose(AuthError, _Error);

    function AuthError() {
      var _this;

      _this = _Error.call(this, 'Authorization required') || this;
      _this.name = 'AuthError';
      _this.isAuthError = true;
      return _this;
    }

    return AuthError;
  }( /*#__PURE__*/_wrapNativeSuper(Error));

  module.exports = AuthError;
  },{}],7:[function(require,module,exports){
  'use strict';

  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

  var RequestClient = require('./RequestClient');

  var tokenStorage = require('./tokenStorage');

  var _getName = function _getName(id) {
    return id.split('-').map(function (s) {
      return s.charAt(0).toUpperCase() + s.slice(1);
    }).join(' ');
  };

  module.exports = /*#__PURE__*/function (_RequestClient) {
    _inheritsLoose(Provider, _RequestClient);

    function Provider(uppy, opts) {
      var _this;

      _this = _RequestClient.call(this, uppy, opts) || this;
      _this.provider = opts.provider;
      _this.id = _this.provider;
      _this.name = _this.opts.name || _getName(_this.id);
      _this.pluginId = _this.opts.pluginId;
      _this.tokenKey = "companion-" + _this.pluginId + "-auth-token";
      return _this;
    }

    var _proto = Provider.prototype;

    _proto.headers = function headers() {
      return Promise.all([_RequestClient.prototype.headers.call(this), this.getAuthToken()]).then(function (_ref) {
        var headers = _ref[0],
            token = _ref[1];
        return _extends({}, headers, {
          'uppy-auth-token': token
        });
      });
    };

    _proto.onReceiveResponse = function onReceiveResponse(response) {
      response = _RequestClient.prototype.onReceiveResponse.call(this, response);
      var plugin = this.uppy.getPlugin(this.pluginId);
      var oldAuthenticated = plugin.getPluginState().authenticated;
      var authenticated = oldAuthenticated ? response.status !== 401 : response.status < 400;
      plugin.setPluginState({
        authenticated: authenticated
      });
      return response;
    } // @todo(i.olarewaju) consider whether or not this method should be exposed
    ;

    _proto.setAuthToken = function setAuthToken(token) {
      return this.uppy.getPlugin(this.pluginId).storage.setItem(this.tokenKey, token);
    };

    _proto.getAuthToken = function getAuthToken() {
      return this.uppy.getPlugin(this.pluginId).storage.getItem(this.tokenKey);
    };

    _proto.authUrl = function authUrl() {
      return this.hostname + "/" + this.id + "/connect";
    };

    _proto.fileUrl = function fileUrl(id) {
      return this.hostname + "/" + this.id + "/get/" + id;
    };

    _proto.list = function list(directory) {
      return this.get(this.id + "/list/" + (directory || ''));
    };

    _proto.logout = function logout() {
      var _this2 = this;

      return this.get(this.id + "/logout").then(function (response) {
        return Promise.all([response, _this2.uppy.getPlugin(_this2.pluginId).storage.removeItem(_this2.tokenKey)]);
      }).then(function (_ref2) {
        var response = _ref2[0];
        return response;
      });
    };

    Provider.initPlugin = function initPlugin(plugin, opts, defaultOpts) {
      plugin.type = 'acquirer';
      plugin.files = [];

      if (defaultOpts) {
        plugin.opts = _extends({}, defaultOpts, opts);
      }

      if (opts.serverUrl || opts.serverPattern) {
        throw new Error('`serverUrl` and `serverPattern` have been renamed to `companionUrl` and `companionAllowedHosts` respectively in the 0.30.5 release. Please consult the docs (for example, https://uppy.io/docs/instagram/ for the Instagram plugin) and use the updated options.`');
      }

      if (opts.companionAllowedHosts) {
        var pattern = opts.companionAllowedHosts; // validate companionAllowedHosts param

        if (typeof pattern !== 'string' && !Array.isArray(pattern) && !(pattern instanceof RegExp)) {
          throw new TypeError(plugin.id + ": the option \"companionAllowedHosts\" must be one of string, Array, RegExp");
        }

        plugin.opts.companionAllowedHosts = pattern;
      } else {
        // does not start with https://
        if (/^(?!https?:\/\/).*$/i.test(opts.companionUrl)) {
          plugin.opts.companionAllowedHosts = "https://" + opts.companionUrl.replace(/^\/\//, '');
        } else {
          plugin.opts.companionAllowedHosts = opts.companionUrl;
        }
      }

      plugin.storage = plugin.opts.storage || tokenStorage;
    };

    return Provider;
  }(RequestClient);
  },{"./RequestClient":8,"./tokenStorage":12}],8:[function(require,module,exports){
  'use strict';

  var _class, _temp;

  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

  function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

  var AuthError = require('./AuthError');

  var fetchWithNetworkError = require('@uppy/utils/lib/fetchWithNetworkError'); // Remove the trailing slash so we can always safely append /xyz.


  function stripSlash(url) {
    return url.replace(/\/$/, '');
  }

  module.exports = (_temp = _class = /*#__PURE__*/function () {
    function RequestClient(uppy, opts) {
      this.uppy = uppy;
      this.opts = opts;
      this.onReceiveResponse = this.onReceiveResponse.bind(this);
      this.allowedHeaders = ['accept', 'content-type', 'uppy-auth-token'];
      this.preflightDone = false;
    }

    var _proto = RequestClient.prototype;

    _proto.headers = function headers() {
      var userHeaders = this.opts.companionHeaders || this.opts.serverHeaders || {};
      return Promise.resolve(_extends({}, this.defaultHeaders, userHeaders));
    };

    _proto._getPostResponseFunc = function _getPostResponseFunc(skip) {
      var _this = this;

      return function (response) {
        if (!skip) {
          return _this.onReceiveResponse(response);
        }

        return response;
      };
    };

    _proto.onReceiveResponse = function onReceiveResponse(response) {
      var state = this.uppy.getState();
      var companion = state.companion || {};
      var host = this.opts.companionUrl;
      var headers = response.headers; // Store the self-identified domain name for the Companion instance we just hit.

      if (headers.has('i-am') && headers.get('i-am') !== companion[host]) {
        var _extends2;

        this.uppy.setState({
          companion: _extends({}, companion, (_extends2 = {}, _extends2[host] = headers.get('i-am'), _extends2))
        });
      }

      return response;
    };

    _proto._getUrl = function _getUrl(url) {
      if (/^(https?:|)\/\//.test(url)) {
        return url;
      }

      return this.hostname + "/" + url;
    };

    _proto._json = function _json(res) {
      if (res.status === 401) {
        throw new AuthError();
      }

      if (res.status < 200 || res.status > 300) {
        var errMsg = "Failed request with status: " + res.status + ". " + res.statusText;
        return res.json().then(function (errData) {
          errMsg = errData.message ? errMsg + " message: " + errData.message : errMsg;
          errMsg = errData.requestId ? errMsg + " request-Id: " + errData.requestId : errMsg;
          throw new Error(errMsg);
        }).catch(function () {
          throw new Error(errMsg);
        });
      }

      return res.json();
    };

    _proto.preflight = function preflight(path) {
      var _this2 = this;

      if (this.preflightDone) {
        return Promise.resolve(this.allowedHeaders.slice());
      }

      return fetch(this._getUrl(path), {
        method: 'OPTIONS'
      }).then(function (response) {
        if (response.headers.has('access-control-allow-headers')) {
          _this2.allowedHeaders = response.headers.get('access-control-allow-headers').split(',').map(function (headerName) {
            return headerName.trim().toLowerCase();
          });
        }

        _this2.preflightDone = true;
        return _this2.allowedHeaders.slice();
      }).catch(function (err) {
        _this2.uppy.log("[CompanionClient] unable to make preflight request " + err, 'warning');

        _this2.preflightDone = true;
        return _this2.allowedHeaders.slice();
      });
    };

    _proto.preflightAndHeaders = function preflightAndHeaders(path) {
      var _this3 = this;

      return Promise.all([this.preflight(path), this.headers()]).then(function (_ref) {
        var allowedHeaders = _ref[0],
            headers = _ref[1];
        // filter to keep only allowed Headers
        Object.keys(headers).forEach(function (header) {
          if (allowedHeaders.indexOf(header.toLowerCase()) === -1) {
            _this3.uppy.log("[CompanionClient] excluding unallowed header " + header);

            delete headers[header];
          }
        });
        return headers;
      });
    };

    _proto.get = function get(path, skipPostResponse) {
      var _this4 = this;

      return this.preflightAndHeaders(path).then(function (headers) {
        return fetchWithNetworkError(_this4._getUrl(path), {
          method: 'get',
          headers: headers,
          credentials: 'same-origin'
        });
      }).then(this._getPostResponseFunc(skipPostResponse)).then(function (res) {
        return _this4._json(res);
      }).catch(function (err) {
        err = err.isAuthError ? err : new Error("Could not get " + _this4._getUrl(path) + ". " + err);
        return Promise.reject(err);
      });
    };

    _proto.post = function post(path, data, skipPostResponse) {
      var _this5 = this;

      return this.preflightAndHeaders(path).then(function (headers) {
        return fetchWithNetworkError(_this5._getUrl(path), {
          method: 'post',
          headers: headers,
          credentials: 'same-origin',
          body: JSON.stringify(data)
        });
      }).then(this._getPostResponseFunc(skipPostResponse)).then(function (res) {
        return _this5._json(res);
      }).catch(function (err) {
        err = err.isAuthError ? err : new Error("Could not post " + _this5._getUrl(path) + ". " + err);
        return Promise.reject(err);
      });
    };

    _proto.delete = function _delete(path, data, skipPostResponse) {
      var _this6 = this;

      return this.preflightAndHeaders(path).then(function (headers) {
        return fetchWithNetworkError(_this6.hostname + "/" + path, {
          method: 'delete',
          headers: headers,
          credentials: 'same-origin',
          body: data ? JSON.stringify(data) : null
        });
      }).then(this._getPostResponseFunc(skipPostResponse)).then(function (res) {
        return _this6._json(res);
      }).catch(function (err) {
        err = err.isAuthError ? err : new Error("Could not delete " + _this6._getUrl(path) + ". " + err);
        return Promise.reject(err);
      });
    };

    _createClass(RequestClient, [{
      key: "hostname",
      get: function get() {
        var _this$uppy$getState = this.uppy.getState(),
            companion = _this$uppy$getState.companion;

        var host = this.opts.companionUrl;
        return stripSlash(companion && companion[host] ? companion[host] : host);
      }
    }, {
      key: "defaultHeaders",
      get: function get() {
        return {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          'Uppy-Versions': "@uppy/companion-client=" + RequestClient.VERSION
        };
      }
    }]);

    return RequestClient;
  }(), _class.VERSION = "1.6.1", _temp);
  },{"./AuthError":6,"@uppy/utils/lib/fetchWithNetworkError":26}],9:[function(require,module,exports){
  'use strict';

  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

  var RequestClient = require('./RequestClient');

  var _getName = function _getName(id) {
    return id.split('-').map(function (s) {
      return s.charAt(0).toUpperCase() + s.slice(1);
    }).join(' ');
  };

  module.exports = /*#__PURE__*/function (_RequestClient) {
    _inheritsLoose(SearchProvider, _RequestClient);

    function SearchProvider(uppy, opts) {
      var _this;

      _this = _RequestClient.call(this, uppy, opts) || this;
      _this.provider = opts.provider;
      _this.id = _this.provider;
      _this.name = _this.opts.name || _getName(_this.id);
      _this.pluginId = _this.opts.pluginId;
      return _this;
    }

    var _proto = SearchProvider.prototype;

    _proto.fileUrl = function fileUrl(id) {
      return this.hostname + "/search/" + this.id + "/get/" + id;
    };

    _proto.search = function search(text, queries) {
      queries = queries ? "&" + queries : '';
      return this.get("search/" + this.id + "/list?q=" + encodeURIComponent(text) + queries);
    };

    return SearchProvider;
  }(RequestClient);
  },{"./RequestClient":8}],10:[function(require,module,exports){
  var ee = require('namespace-emitter');

  module.exports = /*#__PURE__*/function () {
    function UppySocket(opts) {
      this.opts = opts;
      this._queued = [];
      this.isOpen = false;
      this.emitter = ee();
      this._handleMessage = this._handleMessage.bind(this);
      this.close = this.close.bind(this);
      this.emit = this.emit.bind(this);
      this.on = this.on.bind(this);
      this.once = this.once.bind(this);
      this.send = this.send.bind(this);

      if (!opts || opts.autoOpen !== false) {
        this.open();
      }
    }

    var _proto = UppySocket.prototype;

    _proto.open = function open() {
      var _this = this;

      this.socket = new WebSocket(this.opts.target);

      this.socket.onopen = function (e) {
        _this.isOpen = true;

        while (_this._queued.length > 0 && _this.isOpen) {
          var first = _this._queued[0];

          _this.send(first.action, first.payload);

          _this._queued = _this._queued.slice(1);
        }
      };

      this.socket.onclose = function (e) {
        _this.isOpen = false;
      };

      this.socket.onmessage = this._handleMessage;
    };

    _proto.close = function close() {
      if (this.socket) {
        this.socket.close();
      }
    };

    _proto.send = function send(action, payload) {
      // attach uuid
      if (!this.isOpen) {
        this._queued.push({
          action: action,
          payload: payload
        });

        return;
      }

      this.socket.send(JSON.stringify({
        action: action,
        payload: payload
      }));
    };

    _proto.on = function on(action, handler) {
      this.emitter.on(action, handler);
    };

    _proto.emit = function emit(action, payload) {
      this.emitter.emit(action, payload);
    };

    _proto.once = function once(action, handler) {
      this.emitter.once(action, handler);
    };

    _proto._handleMessage = function _handleMessage(e) {
      try {
        var message = JSON.parse(e.data);
        this.emit(message.action, message.payload);
      } catch (err) {
        console.log(err);
      }
    };

    return UppySocket;
  }();
  },{"namespace-emitter":49}],11:[function(require,module,exports){
  'use strict';
  /**
   * Manages communications with Companion
   */

  var RequestClient = require('./RequestClient');

  var Provider = require('./Provider');

  var SearchProvider = require('./SearchProvider');

  var Socket = require('./Socket');

  module.exports = {
    RequestClient: RequestClient,
    Provider: Provider,
    SearchProvider: SearchProvider,
    Socket: Socket
  };
  },{"./Provider":7,"./RequestClient":8,"./SearchProvider":9,"./Socket":10}],12:[function(require,module,exports){
  'use strict';
  /**
   * This module serves as an Async wrapper for LocalStorage
   */

  module.exports.setItem = function (key, value) {
    return new Promise(function (resolve) {
      localStorage.setItem(key, value);
      resolve();
    });
  };

  module.exports.getItem = function (key) {
    return Promise.resolve(localStorage.getItem(key));
  };

  module.exports.removeItem = function (key) {
    return new Promise(function (resolve) {
      localStorage.removeItem(key);
      resolve();
    });
  };
  },{}],13:[function(require,module,exports){
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  var preact = require('preact');

  var findDOMElement = require('@uppy/utils/lib/findDOMElement');
  /**
   * Defer a frequent call to the microtask queue.
   */


  function debounce(fn) {
    var calling = null;
    var latestArgs = null;
    return function () {
      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }

      latestArgs = args;

      if (!calling) {
        calling = Promise.resolve().then(function () {
          calling = null; // At this point `args` may be different from the most
          // recent state, if multiple calls happened since this task
          // was queued. So we use the `latestArgs`, which definitely
          // is the most recent call.

          return fn.apply(void 0, latestArgs);
        });
      }

      return calling;
    };
  }
  /**
   * Boilerplate that all Plugins share - and should not be used
   * directly. It also shows which methods final plugins should implement/override,
   * this deciding on structure.
   *
   * @param {object} main Uppy core object
   * @param {object} object with plugin options
   * @returns {Array|string} files or success/fail message
   */


  module.exports = /*#__PURE__*/function () {
    function Plugin(uppy, opts) {
      this.uppy = uppy;
      this.opts = opts || {};
      this.update = this.update.bind(this);
      this.mount = this.mount.bind(this);
      this.install = this.install.bind(this);
      this.uninstall = this.uninstall.bind(this);
    }

    var _proto = Plugin.prototype;

    _proto.getPluginState = function getPluginState() {
      var _this$uppy$getState = this.uppy.getState(),
          plugins = _this$uppy$getState.plugins;

      return plugins[this.id] || {};
    };

    _proto.setPluginState = function setPluginState(update) {
      var _extends2;

      var _this$uppy$getState2 = this.uppy.getState(),
          plugins = _this$uppy$getState2.plugins;

      this.uppy.setState({
        plugins: _extends({}, plugins, (_extends2 = {}, _extends2[this.id] = _extends({}, plugins[this.id], update), _extends2))
      });
    };

    _proto.setOptions = function setOptions(newOpts) {
      this.opts = _extends({}, this.opts, newOpts);
      this.setPluginState(); // so that UI re-renders with new options
    };

    _proto.update = function update(state) {
      if (typeof this.el === 'undefined') {
        return;
      }

      if (this._updateUI) {
        this._updateUI(state);
      }
    } // Called after every state update, after everything's mounted. Debounced.
    ;

    _proto.afterUpdate = function afterUpdate() {}
    /**
     * Called when plugin is mounted, whether in DOM or into another plugin.
     * Needed because sometimes plugins are mounted separately/after `install`,
     * so this.el and this.parent might not be available in `install`.
     * This is the case with @uppy/react plugins, for example.
     */
    ;

    _proto.onMount = function onMount() {}
    /**
     * Check if supplied `target` is a DOM element or an `object`.
     * If it’s an object — target is a plugin, and we search `plugins`
     * for a plugin with same name and return its target.
     *
     * @param {string|object} target
     *
     */
    ;

    _proto.mount = function mount(target, plugin) {
      var _this = this;

      var callerPluginName = plugin.id;
      var targetElement = findDOMElement(target);

      if (targetElement) {
        this.isTargetDOMEl = true; // API for plugins that require a synchronous rerender.

        this.rerender = function (state) {
          // plugin could be removed, but this.rerender is debounced below,
          // so it could still be called even after uppy.removePlugin or uppy.close
          // hence the check
          if (!_this.uppy.getPlugin(_this.id)) return;
          _this.el = preact.render(_this.render(state), targetElement, _this.el);

          _this.afterUpdate();
        };

        this._updateUI = debounce(this.rerender);
        this.uppy.log("Installing " + callerPluginName + " to a DOM element '" + target + "'"); // clear everything inside the target container

        if (this.opts.replaceTargetContent) {
          targetElement.innerHTML = '';
        }

        this.el = preact.render(this.render(this.uppy.getState()), targetElement);
        this.onMount();
        return this.el;
      }

      var targetPlugin;

      if (typeof target === 'object' && target instanceof Plugin) {
        // Targeting a plugin *instance*
        targetPlugin = target;
      } else if (typeof target === 'function') {
        // Targeting a plugin type
        var Target = target; // Find the target plugin instance.

        this.uppy.iteratePlugins(function (plugin) {
          if (plugin instanceof Target) {
            targetPlugin = plugin;
            return false;
          }
        });
      }

      if (targetPlugin) {
        this.uppy.log("Installing " + callerPluginName + " to " + targetPlugin.id);
        this.parent = targetPlugin;
        this.el = targetPlugin.addTarget(plugin);
        this.onMount();
        return this.el;
      }

      this.uppy.log("Not installing " + callerPluginName);
      var message = "Invalid target option given to " + callerPluginName + ".";

      if (typeof target === 'function') {
        message += ' The given target is not a Plugin class. ' + 'Please check that you\'re not specifying a React Component instead of a plugin. ' + 'If you are using @uppy/* packages directly, make sure you have only 1 version of @uppy/core installed: ' + 'run `npm ls @uppy/core` on the command line and verify that all the versions match and are deduped correctly.';
      } else {
        message += 'If you meant to target an HTML element, please make sure that the element exists. ' + 'Check that the <script> tag initializing Uppy is right before the closing </body> tag at the end of the page. ' + '(see https://github.com/transloadit/uppy/issues/1042)\n\n' + 'If you meant to target a plugin, please confirm that your `import` statements or `require` calls are correct.';
      }

      throw new Error(message);
    };

    _proto.render = function render(state) {
      throw new Error('Extend the render method to add your plugin to a DOM element');
    };

    _proto.addTarget = function addTarget(plugin) {
      throw new Error('Extend the addTarget method to add your plugin to another plugin\'s target');
    };

    _proto.unmount = function unmount() {
      if (this.isTargetDOMEl && this.el && this.el.parentNode) {
        this.el.parentNode.removeChild(this.el);
      }
    };

    _proto.install = function install() {};

    _proto.uninstall = function uninstall() {
      this.unmount();
    };

    return Plugin;
  }();
  },{"@uppy/utils/lib/findDOMElement":27,"preact":50}],14:[function(require,module,exports){
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

  function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

  function _wrapNativeSuper(Class) { var _cache = typeof Map === "function" ? new Map() : undefined; _wrapNativeSuper = function _wrapNativeSuper(Class) { if (Class === null || !_isNativeFunction(Class)) return Class; if (typeof Class !== "function") { throw new TypeError("Super expression must either be null or a function"); } if (typeof _cache !== "undefined") { if (_cache.has(Class)) return _cache.get(Class); _cache.set(Class, Wrapper); } function Wrapper() { return _construct(Class, arguments, _getPrototypeOf(this).constructor); } Wrapper.prototype = Object.create(Class.prototype, { constructor: { value: Wrapper, enumerable: false, writable: true, configurable: true } }); return _setPrototypeOf(Wrapper, Class); }; return _wrapNativeSuper(Class); }

  function _construct(Parent, args, Class) { if (_isNativeReflectConstruct()) { _construct = Reflect.construct; } else { _construct = function _construct(Parent, args, Class) { var a = [null]; a.push.apply(a, args); var Constructor = Function.bind.apply(Parent, a); var instance = new Constructor(); if (Class) _setPrototypeOf(instance, Class.prototype); return instance; }; } return _construct.apply(null, arguments); }

  function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }

  function _isNativeFunction(fn) { return Function.toString.call(fn).indexOf("[native code]") !== -1; }

  function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }

  function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

  var Translator = require('@uppy/utils/lib/Translator');

  var ee = require('namespace-emitter');

  var cuid = require('cuid');

  var throttle = require('lodash.throttle');

  var prettierBytes = require('@transloadit/prettier-bytes');

  var match = require('mime-match');

  var DefaultStore = require('@uppy/store-default');

  var getFileType = require('@uppy/utils/lib/getFileType');

  var getFileNameAndExtension = require('@uppy/utils/lib/getFileNameAndExtension');

  var generateFileID = require('@uppy/utils/lib/generateFileID');

  var supportsUploadProgress = require('./supportsUploadProgress');

  var _require = require('./loggers'),
      justErrorsLogger = _require.justErrorsLogger,
      debugLogger = _require.debugLogger;

  var Plugin = require('./Plugin'); // Exported from here.


  var RestrictionError = /*#__PURE__*/function (_Error) {
    _inheritsLoose(RestrictionError, _Error);

    function RestrictionError() {
      var _this;

      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }

      _this = _Error.call.apply(_Error, [this].concat(args)) || this;
      _this.isRestriction = true;
      return _this;
    }

    return RestrictionError;
  }( /*#__PURE__*/_wrapNativeSuper(Error));
  /**
   * Uppy Core module.
   * Manages plugins, state updates, acts as an event bus,
   * adds/removes files and metadata.
   */


  var Uppy = /*#__PURE__*/function () {
    /**
     * Instantiate Uppy
     *
     * @param {object} opts — Uppy options
     */
    function Uppy(opts) {
      var _this2 = this;

      this.defaultLocale = {
        strings: {
          addBulkFilesFailed: {
            0: 'Failed to add %{smart_count} file due to an internal error',
            1: 'Failed to add %{smart_count} files due to internal errors'
          },
          youCanOnlyUploadX: {
            0: 'Es können maximal %{smart_count} Bilder gleichzeitig hochgeladen werden.',
            1: 'Es können maximal %{smart_count} Bilder gleichzeitig hochgeladen werden.'
          },
          youHaveToAtLeastSelectX: {
            0: 'You have to select at least %{smart_count} file',
            1: 'You have to select at least %{smart_count} files'
          },
          // The default `exceedsSize2` string only combines the `exceedsSize` string (%{backwardsCompat}) with the size.
          // Locales can override `exceedsSize2` to specify a different word order. This is for backwards compat with
          // Uppy 1.9.x and below which did a naive concatenation of `exceedsSize2 + size` instead of using a locale-specific
          // substitution.
          // TODO: In 2.0 `exceedsSize2` should be removed in and `exceedsSize` updated to use substitution.
          exceedsSize2: '%{backwardsCompat} %{size}',
          exceedsSize: 'Zu große Bilder können nicht hochgeladen werden. Maximale Dateigröße:',
          inferiorSize: 'This file is smaller than the allowed size of %{size}',
          youCanOnlyUploadFileTypes: 'Es können nur folgende Formate hochgeladen werden: %{types}',
          noNewAlreadyUploading: 'Cannot add new files: already uploading',
          noDuplicates: 'Folgende Datei existiert bereits: \'%{fileName}\'',
          companionError: 'Connection with Companion failed',
          companionUnauthorizeHint: 'To unauthorize to your %{provider} account, please go to %{url}',
          failedToUpload: 'Failed to upload %{file}',
          noInternetConnection: 'Fehlende Internetverbindung ...',
          connectedToInternet: 'Internetverbindung hergestellt',
          // Strings for remote providers
          noFilesFound: 'You have no files or folders here',
          selectX: {
            0: 'Select %{smart_count}',
            1: 'Select %{smart_count}'
          },
          selectAllFilesFromFolderNamed: 'Select all files from folder %{name}',
          unselectAllFilesFromFolderNamed: 'Unselect all files from folder %{name}',
          selectFileNamed: 'Select file %{name}',
          unselectFileNamed: 'Unselect file %{name}',
          openFolderNamed: 'Open folder %{name}',
          cancel: 'Cancel',
          logOut: 'Log out',
          filter: 'Filter',
          resetFilter: 'Reset filter',
          loading: 'Loading...',
          authenticateWithTitle: 'Please authenticate with %{pluginName} to select files',
          authenticateWith: 'Connect to %{pluginName}',
          searchImages: 'Search for images',
          enterTextToSearch: 'Enter text to search for images',
          backToSearch: 'Back to Search',
          emptyFolderAdded: 'No files were added from empty folder',
          folderAdded: {
            0: 'Added %{smart_count} file from %{folder}',
            1: 'Added %{smart_count} files from %{folder}'
          }
        }
      };
      var defaultOptions = {
        id: 'uppy',
        autoProceed: false,
        allowMultipleUploads: true,
        debug: false,
        restrictions: {
          maxFileSize: null,
          minFileSize: null,
          maxTotalFileSize: null,
          maxNumberOfFiles: null,
          minNumberOfFiles: null,
          allowedFileTypes: null
        },
        meta: {},
        onBeforeFileAdded: function onBeforeFileAdded(currentFile, files) {
          return currentFile;
        },
        onBeforeUpload: function onBeforeUpload(files) {
          return files;
        },
        store: DefaultStore(),
        logger: justErrorsLogger,
        infoTimeout: 5000
      }; // Merge default options with the ones set by user,
      // making sure to merge restrictions too

      this.opts = _extends({}, defaultOptions, opts, {
        restrictions: _extends({}, defaultOptions.restrictions, opts && opts.restrictions)
      }); // Support debug: true for backwards-compatability, unless logger is set in opts
      // opts instead of this.opts to avoid comparing objects — we set logger: justErrorsLogger in defaultOptions

      if (opts && opts.logger && opts.debug) {
        this.log('You are using a custom `logger`, but also set `debug: true`, which uses built-in logger to output logs to console. Ignoring `debug: true` and using your custom `logger`.', 'warning');
      } else if (opts && opts.debug) {
        this.opts.logger = debugLogger;
      }

      this.log("Using Core v" + this.constructor.VERSION);

      if (this.opts.restrictions.allowedFileTypes && this.opts.restrictions.allowedFileTypes !== null && !Array.isArray(this.opts.restrictions.allowedFileTypes)) {
        throw new TypeError('`restrictions.allowedFileTypes` must be an array');
      }

      this.i18nInit(); // Container for different types of plugins

      this.plugins = {};
      this.getState = this.getState.bind(this);
      this.getPlugin = this.getPlugin.bind(this);
      this.setFileMeta = this.setFileMeta.bind(this);
      this.setFileState = this.setFileState.bind(this);
      this.log = this.log.bind(this);
      this.info = this.info.bind(this);
      this.hideInfo = this.hideInfo.bind(this);
      this.addFile = this.addFile.bind(this);
      this.removeFile = this.removeFile.bind(this);
      this.pauseResume = this.pauseResume.bind(this);
      this.validateRestrictions = this.validateRestrictions.bind(this); // ___Why throttle at 500ms?
      //    - We must throttle at >250ms for superfocus in Dashboard to work well (because animation takes 0.25s, and we want to wait for all animations to be over before refocusing).
      //    [Practical Check]: if thottle is at 100ms, then if you are uploading a file, and click 'ADD MORE FILES', - focus won't activate in Firefox.
      //    - We must throttle at around >500ms to avoid performance lags.
      //    [Practical Check] Firefox, try to upload a big file for a prolonged period of time. Laptop will start to heat up.

      this._calculateProgress = throttle(this._calculateProgress.bind(this), 500, {
        leading: true,
        trailing: true
      });
      this.updateOnlineStatus = this.updateOnlineStatus.bind(this);
      this.resetProgress = this.resetProgress.bind(this);
      this.pauseAll = this.pauseAll.bind(this);
      this.resumeAll = this.resumeAll.bind(this);
      this.retryAll = this.retryAll.bind(this);
      this.cancelAll = this.cancelAll.bind(this);
      this.retryUpload = this.retryUpload.bind(this);
      this.upload = this.upload.bind(this);
      this.emitter = ee();
      this.on = this.on.bind(this);
      this.off = this.off.bind(this);
      this.once = this.emitter.once.bind(this.emitter);
      this.emit = this.emitter.emit.bind(this.emitter);
      this.preProcessors = [];
      this.uploaders = [];
      this.postProcessors = [];
      this.store = this.opts.store;
      this.setState({
        plugins: {},
        files: {},
        currentUploads: {},
        allowNewUpload: true,
        capabilities: {
          uploadProgress: supportsUploadProgress(),
          individualCancellation: true,
          resumableUploads: false
        },
        totalProgress: 0,
        meta: _extends({}, this.opts.meta),
        info: {
          isHidden: true,
          type: 'info',
          message: ''
        }
      });
      this._storeUnsubscribe = this.store.subscribe(function (prevState, nextState, patch) {
        _this2.emit('state-update', prevState, nextState, patch);

        _this2.updateAll(nextState);
      }); // Exposing uppy object on window for debugging and testing

      if (this.opts.debug && typeof window !== 'undefined') {
        window[this.opts.id] = this;
      }

      this._addListeners(); // Re-enable if we’ll need some capabilities on boot, like isMobileDevice
      // this._setCapabilities()

    } // _setCapabilities = () => {
    //   const capabilities = {
    //     isMobileDevice: isMobileDevice()
    //   }
    //   this.setState({
    //     ...this.getState().capabilities,
    //     capabilities
    //   })
    // }


    var _proto = Uppy.prototype;

    _proto.on = function on(event, callback) {
      this.emitter.on(event, callback);
      return this;
    };

    _proto.off = function off(event, callback) {
      this.emitter.off(event, callback);
      return this;
    }
    /**
     * Iterate on all plugins and run `update` on them.
     * Called each time state changes.
     *
     */
    ;

    _proto.updateAll = function updateAll(state) {
      this.iteratePlugins(function (plugin) {
        plugin.update(state);
      });
    }
    /**
     * Updates state with a patch
     *
     * @param {object} patch {foo: 'bar'}
     */
    ;

    _proto.setState = function setState(patch) {
      this.store.setState(patch);
    }
    /**
     * Returns current state.
     *
     * @returns {object}
     */
    ;

    _proto.getState = function getState() {
      return this.store.getState();
    }
    /**
     * Back compat for when uppy.state is used instead of uppy.getState().
     */
    ;

    /**
     * Shorthand to set state for a specific file.
     */
    _proto.setFileState = function setFileState(fileID, state) {
      var _extends2;

      if (!this.getState().files[fileID]) {
        throw new Error("Can\u2019t set state for " + fileID + " (the file could have been removed)");
      }

      this.setState({
        files: _extends({}, this.getState().files, (_extends2 = {}, _extends2[fileID] = _extends({}, this.getState().files[fileID], state), _extends2))
      });
    };

    _proto.i18nInit = function i18nInit() {
      this.translator = new Translator([this.defaultLocale, this.opts.locale]);
      this.locale = this.translator.locale;
      this.i18n = this.translator.translate.bind(this.translator);
      this.i18nArray = this.translator.translateArray.bind(this.translator);
    };

    _proto.setOptions = function setOptions(newOpts) {
      this.opts = _extends({}, this.opts, newOpts, {
        restrictions: _extends({}, this.opts.restrictions, newOpts && newOpts.restrictions)
      });

      if (newOpts.meta) {
        this.setMeta(newOpts.meta);
      }

      this.i18nInit();

      if (newOpts.locale) {
        this.iteratePlugins(function (plugin) {
          plugin.setOptions();
        });
      }

      this.setState(); // so that UI re-renders with new options
    };

    _proto.resetProgress = function resetProgress() {
      var defaultProgress = {
        percentage: 0,
        bytesUploaded: 0,
        uploadComplete: false,
        uploadStarted: null
      };

      var files = _extends({}, this.getState().files);

      var updatedFiles = {};
      Object.keys(files).forEach(function (fileID) {
        var updatedFile = _extends({}, files[fileID]);

        updatedFile.progress = _extends({}, updatedFile.progress, defaultProgress);
        updatedFiles[fileID] = updatedFile;
      });
      this.setState({
        files: updatedFiles,
        totalProgress: 0
      });
      this.emit('reset-progress');
    };

    _proto.addPreProcessor = function addPreProcessor(fn) {
      this.preProcessors.push(fn);
    };

    _proto.removePreProcessor = function removePreProcessor(fn) {
      var i = this.preProcessors.indexOf(fn);

      if (i !== -1) {
        this.preProcessors.splice(i, 1);
      }
    };

    _proto.addPostProcessor = function addPostProcessor(fn) {
      this.postProcessors.push(fn);
    };

    _proto.removePostProcessor = function removePostProcessor(fn) {
      var i = this.postProcessors.indexOf(fn);

      if (i !== -1) {
        this.postProcessors.splice(i, 1);
      }
    };

    _proto.addUploader = function addUploader(fn) {
      this.uploaders.push(fn);
    };

    _proto.removeUploader = function removeUploader(fn) {
      var i = this.uploaders.indexOf(fn);

      if (i !== -1) {
        this.uploaders.splice(i, 1);
      }
    };

    _proto.setMeta = function setMeta(data) {
      var updatedMeta = _extends({}, this.getState().meta, data);

      var updatedFiles = _extends({}, this.getState().files);

      Object.keys(updatedFiles).forEach(function (fileID) {
        updatedFiles[fileID] = _extends({}, updatedFiles[fileID], {
          meta: _extends({}, updatedFiles[fileID].meta, data)
        });
      });
      this.log('Adding metadata:');
      this.log(data);
      this.setState({
        meta: updatedMeta,
        files: updatedFiles
      });
    };

    _proto.setFileMeta = function setFileMeta(fileID, data) {
      var updatedFiles = _extends({}, this.getState().files);

      if (!updatedFiles[fileID]) {
        this.log('Was trying to set metadata for a file that has been removed: ', fileID);
        return;
      }

      var newMeta = _extends({}, updatedFiles[fileID].meta, data);

      updatedFiles[fileID] = _extends({}, updatedFiles[fileID], {
        meta: newMeta
      });
      this.setState({
        files: updatedFiles
      });
    }
    /**
     * Get a file object.
     *
     * @param {string} fileID The ID of the file object to return.
     */
    ;

    _proto.getFile = function getFile(fileID) {
      return this.getState().files[fileID];
    }
    /**
     * Get all files in an array.
     */
    ;

    _proto.getFiles = function getFiles() {
      var _this$getState = this.getState(),
          files = _this$getState.files;

      return Object.keys(files).map(function (fileID) {
        return files[fileID];
      });
    }
    /**
     * A public wrapper for _checkRestrictions — checks if a file passes a set of restrictions.
     * For use in UI pluigins (like Providers), to disallow selecting files that won’t pass restrictions.
     *
     * @param {object} file object to check
     * @param {Array} [files] array to check maxNumberOfFiles and maxTotalFileSize
     * @returns {object} { result: true/false, reason: why file didn’t pass restrictions }
     */
    ;

    _proto.validateRestrictions = function validateRestrictions(file, files) {
      try {
        this._checkRestrictions(file, files);

        return {
          result: true
        };
      } catch (err) {
        return {
          result: false,
          reason: err.message
        };
      }
    }
    /**
     * Check if file passes a set of restrictions set in options: maxFileSize, minFileSize,
     * maxNumberOfFiles and allowedFileTypes.
     *
     * @param {object} file object to check
     * @param {Array} [files] array to check maxNumberOfFiles and maxTotalFileSize
     * @private
     */
    ;

    _proto._checkRestrictions = function _checkRestrictions(file, files) {
      if (files === void 0) {
        files = this.getFiles();
      }

      var _this$opts$restrictio = this.opts.restrictions,
          maxFileSize = _this$opts$restrictio.maxFileSize,
          minFileSize = _this$opts$restrictio.minFileSize,
          maxTotalFileSize = _this$opts$restrictio.maxTotalFileSize,
          maxNumberOfFiles = _this$opts$restrictio.maxNumberOfFiles,
          allowedFileTypes = _this$opts$restrictio.allowedFileTypes;

      if (maxNumberOfFiles) {
        if (files.length + 1 > maxNumberOfFiles) {
          throw new RestrictionError("" + this.i18n('youCanOnlyUploadX', {
            smart_count: maxNumberOfFiles
          }));
        }
      }

      if (allowedFileTypes) {
        var isCorrectFileType = allowedFileTypes.some(function (type) {
          // check if this is a mime-type
          if (type.indexOf('/') > -1) {
            if (!file.type) return false;
            return match(file.type.replace(/;.*?$/, ''), type);
          } // otherwise this is likely an extension


          if (type[0] === '.' && file.extension) {
            return file.extension.toLowerCase() === type.substr(1).toLowerCase();
          }

          return false;
        });

        if (!isCorrectFileType) {
          var allowedFileTypesString = allowedFileTypes.join(', ');
          throw new RestrictionError(this.i18n('youCanOnlyUploadFileTypes', {
            types: allowedFileTypesString
          }));
        }
      } // We can't check maxTotalFileSize if the size is unknown.


      if (maxTotalFileSize && file.size != null) {
        var totalFilesSize = 0;
        totalFilesSize += file.size;
        files.forEach(function (file) {
          totalFilesSize += file.size;
        });

        if (totalFilesSize > maxTotalFileSize) {
          throw new RestrictionError(this.i18n('exceedsSize2', {
            backwardsCompat: this.i18n('exceedsSize'),
            size: prettierBytes(maxTotalFileSize)
          }));
        }
      } // We can't check maxFileSize if the size is unknown.


      if (maxFileSize && file.size != null) {
        if (file.size > maxFileSize) {
          throw new RestrictionError(this.i18n('exceedsSize2', {
            backwardsCompat: this.i18n('exceedsSize'),
            size: prettierBytes(maxFileSize)
          }));
        }
      } // We can't check minFileSize if the size is unknown.


      if (minFileSize && file.size != null) {
        if (file.size < minFileSize) {
          throw new RestrictionError(this.i18n('inferiorSize', {
            size: prettierBytes(minFileSize)
          }));
        }
      }
    }
    /**
     * Check if minNumberOfFiles restriction is reached before uploading.
     *
     * @private
     */
    ;

    _proto._checkMinNumberOfFiles = function _checkMinNumberOfFiles(files) {
      var minNumberOfFiles = this.opts.restrictions.minNumberOfFiles;

      if (Object.keys(files).length < minNumberOfFiles) {
        throw new RestrictionError("" + this.i18n('youHaveToAtLeastSelectX', {
          smart_count: minNumberOfFiles
        }));
      }
    }
    /**
     * Logs an error, sets Informer message, then throws the error.
     * Emits a 'restriction-failed' event if it’s a restriction error
     *
     * @param {object | string} err — Error object or plain string message
     * @param {object} [options]
     * @param {boolean} [options.showInformer=true] — Sometimes developer might want to show Informer manually
     * @param {object} [options.file=null] — File object used to emit the restriction error
     * @param {boolean} [options.throwErr=true] — Errors shouldn’t be thrown, for example, in `upload-error` event
     * @private
     */
    ;

    _proto._showOrLogErrorAndThrow = function _showOrLogErrorAndThrow(err, _temp) {
      var _ref = _temp === void 0 ? {} : _temp,
          _ref$showInformer = _ref.showInformer,
          showInformer = _ref$showInformer === void 0 ? true : _ref$showInformer,
          _ref$file = _ref.file,
          file = _ref$file === void 0 ? null : _ref$file,
          _ref$throwErr = _ref.throwErr,
          throwErr = _ref$throwErr === void 0 ? true : _ref$throwErr;

      var message = typeof err === 'object' ? err.message : err;
      var details = typeof err === 'object' && err.details ? err.details : ''; // Restriction errors should be logged, but not as errors,
      // as they are expected and shown in the UI.

      var logMessageWithDetails = message;

      if (details) {
        logMessageWithDetails += ' ' + details;
      }

      if (err.isRestriction) {
        this.log(logMessageWithDetails);
        this.emit('restriction-failed', file, err);
      } else {
        this.log(logMessageWithDetails, 'error');
      } // Sometimes informer has to be shown manually by the developer,
      // for example, in `onBeforeFileAdded`.


      if (showInformer) {
        this.info({
          message: message,
          details: details
        }, 'error', this.opts.infoTimeout);
      }

      if (throwErr) {
        throw typeof err === 'object' ? err : new Error(err);
      }
    };

    _proto._assertNewUploadAllowed = function _assertNewUploadAllowed(file) {
      var _this$getState2 = this.getState(),
          allowNewUpload = _this$getState2.allowNewUpload;

      if (allowNewUpload === false) {
        this._showOrLogErrorAndThrow(new RestrictionError(this.i18n('noNewAlreadyUploading')), {
          file: file
        });
      }
    }
    /**
     * Create a file state object based on user-provided `addFile()` options.
     *
     * Note this is extremely side-effectful and should only be done when a file state object will be added to state immediately afterward!
     *
     * The `files` value is passed in because it may be updated by the caller without updating the store.
     */
    ;

    _proto._checkAndCreateFileStateObject = function _checkAndCreateFileStateObject(files, file) {
      var fileType = getFileType(file);
      file.type = fileType;
      var onBeforeFileAddedResult = this.opts.onBeforeFileAdded(file, files);

      if (onBeforeFileAddedResult === false) {
        // Don’t show UI info for this error, as it should be done by the developer
        this._showOrLogErrorAndThrow(new RestrictionError('Cannot add the file because onBeforeFileAdded returned false.'), {
          showInformer: false,
          file: file
        });
      }

      if (typeof onBeforeFileAddedResult === 'object' && onBeforeFileAddedResult) {
        file = onBeforeFileAddedResult;
      }

      var fileName;

      if (file.name) {
        fileName = file.name;
      } else if (fileType.split('/')[0] === 'image') {
        fileName = fileType.split('/')[0] + '.' + fileType.split('/')[1];
      } else {
        fileName = 'noname';
      }

      var fileExtension = getFileNameAndExtension(fileName).extension;
      var isRemote = file.isRemote || false;
      var fileID = generateFileID(file);

      if (files[fileID]) {
        this._showOrLogErrorAndThrow(new RestrictionError(this.i18n('noDuplicates', {
          fileName: fileName
        })), {
          file: file
        });
      }

      var meta = file.meta || {};
      meta.name = fileName;
      meta.type = fileType; // `null` means the size is unknown.

      var size = isFinite(file.data.size) ? file.data.size : null;
      var newFile = {
        source: file.source || '',
        id: fileID,
        name: fileName,
        extension: fileExtension || '',
        meta: _extends({}, this.getState().meta, meta),
        type: fileType,
        data: file.data,
        progress: {
          percentage: 0,
          bytesUploaded: 0,
          bytesTotal: size,
          uploadComplete: false,
          uploadStarted: null
        },
        size: size,
        isRemote: isRemote,
        remote: file.remote || '',
        preview: file.preview
      };

      try {
        var filesArray = Object.keys(files).map(function (i) {
          return files[i];
        });

        this._checkRestrictions(newFile, filesArray);
      } catch (err) {
        this._showOrLogErrorAndThrow(err, {
          file: newFile
        });
      }

      return newFile;
    } // Schedule an upload if `autoProceed` is enabled.
    ;

    _proto._startIfAutoProceed = function _startIfAutoProceed() {
      var _this3 = this;

      if (this.opts.autoProceed && !this.scheduledAutoProceed) {
        this.scheduledAutoProceed = setTimeout(function () {
          _this3.scheduledAutoProceed = null;

          _this3.upload().catch(function (err) {
            if (!err.isRestriction) {
              _this3.log(err.stack || err.message || err);
            }
          });
        }, 4);
      }
    }
    /**
     * Add a new file to `state.files`. This will run `onBeforeFileAdded`,
     * try to guess file type in a clever way, check file against restrictions,
     * and start an upload if `autoProceed === true`.
     *
     * @param {object} file object to add
     * @returns {string} id for the added file
     */
    ;

    _proto.addFile = function addFile(file) {
      var _extends3;

      this._assertNewUploadAllowed(file);

      var _this$getState3 = this.getState(),
          files = _this$getState3.files;

      var newFile = this._checkAndCreateFileStateObject(files, file);

      this.setState({
        files: _extends({}, files, (_extends3 = {}, _extends3[newFile.id] = newFile, _extends3))
      });
      this.emit('file-added', newFile);
      this.log("Added file: " + newFile.name + ", " + newFile.id + ", mime type: " + newFile.type);

      this._startIfAutoProceed();

      return newFile.id;
    }
    /**
     * Add multiple files to `state.files`. See the `addFile()` documentation.
     *
     * This cuts some corners for performance, so should typically only be used in cases where there may be a lot of files.
     *
     * If an error occurs while adding a file, it is logged and the user is notified. This is good for UI plugins, but not for programmatic use. Programmatic users should usually still use `addFile()` on individual files.
     */
    ;

    _proto.addFiles = function addFiles(fileDescriptors) {
      var _this4 = this;

      this._assertNewUploadAllowed(); // create a copy of the files object only once


      var files = _extends({}, this.getState().files);

      var newFiles = [];
      var errors = [];

      for (var i = 0; i < fileDescriptors.length; i++) {
        try {
          var newFile = this._checkAndCreateFileStateObject(files, fileDescriptors[i]);

          newFiles.push(newFile);
          files[newFile.id] = newFile;
        } catch (err) {
          if (!err.isRestriction) {
            errors.push(err);
          }
        }
      }

      this.setState({
        files: files
      });
      newFiles.forEach(function (newFile) {
        _this4.emit('file-added', newFile);
      });

      if (newFiles.length > 5) {
        this.log("Added batch of " + newFiles.length + " files");
      } else {
        Object.keys(newFiles).forEach(function (fileID) {
          _this4.log("Added file: " + newFiles[fileID].name + "\n id: " + newFiles[fileID].id + "\n type: " + newFiles[fileID].type);
        });
      }

      if (newFiles.length > 0) {
        this._startIfAutoProceed();
      }

      if (errors.length > 0) {
        var message = 'Multiple errors occurred while adding files:\n';
        errors.forEach(function (subError) {
          message += "\n * " + subError.message;
        });
        this.info({
          message: this.i18n('addBulkFilesFailed', {
            smart_count: errors.length
          }),
          details: message
        }, 'error', this.opts.infoTimeout);
        var err = new Error(message);
        err.errors = errors;
        throw err;
      }
    };

    _proto.removeFiles = function removeFiles(fileIDs, reason) {
      var _this5 = this;

      var _this$getState4 = this.getState(),
          files = _this$getState4.files,
          currentUploads = _this$getState4.currentUploads;

      var updatedFiles = _extends({}, files);

      var updatedUploads = _extends({}, currentUploads);

      var removedFiles = Object.create(null);
      fileIDs.forEach(function (fileID) {
        if (files[fileID]) {
          removedFiles[fileID] = files[fileID];
          delete updatedFiles[fileID];
        }
      }); // Remove files from the `fileIDs` list in each upload.

      function fileIsNotRemoved(uploadFileID) {
        return removedFiles[uploadFileID] === undefined;
      }

      var uploadsToRemove = [];
      Object.keys(updatedUploads).forEach(function (uploadID) {
        var newFileIDs = currentUploads[uploadID].fileIDs.filter(fileIsNotRemoved); // Remove the upload if no files are associated with it anymore.

        if (newFileIDs.length === 0) {
          uploadsToRemove.push(uploadID);
          return;
        }

        updatedUploads[uploadID] = _extends({}, currentUploads[uploadID], {
          fileIDs: newFileIDs
        });
      });
      uploadsToRemove.forEach(function (uploadID) {
        delete updatedUploads[uploadID];
      });
      var stateUpdate = {
        currentUploads: updatedUploads,
        files: updatedFiles
      }; // If all files were removed - allow new uploads!

      if (Object.keys(updatedFiles).length === 0) {
        stateUpdate.allowNewUpload = true;
        stateUpdate.error = null;
      }

      this.setState(stateUpdate);

      this._calculateTotalProgress();

      var removedFileIDs = Object.keys(removedFiles);
      removedFileIDs.forEach(function (fileID) {
        _this5.emit('file-removed', removedFiles[fileID], reason);
      });

      if (removedFileIDs.length > 5) {
        this.log("Removed " + removedFileIDs.length + " files");
      } else {
        this.log("Removed files: " + removedFileIDs.join(', '));
      }
    };

    _proto.removeFile = function removeFile(fileID, reason) {
      if (reason === void 0) {
        reason = null;
      }

      this.removeFiles([fileID], reason);
    };

    _proto.pauseResume = function pauseResume(fileID) {
      if (!this.getState().capabilities.resumableUploads || this.getFile(fileID).uploadComplete) {
        return;
      }

      var wasPaused = this.getFile(fileID).isPaused || false;
      var isPaused = !wasPaused;
      this.setFileState(fileID, {
        isPaused: isPaused
      });
      this.emit('upload-pause', fileID, isPaused);
      return isPaused;
    };

    _proto.pauseAll = function pauseAll() {
      var updatedFiles = _extends({}, this.getState().files);

      var inProgressUpdatedFiles = Object.keys(updatedFiles).filter(function (file) {
        return !updatedFiles[file].progress.uploadComplete && updatedFiles[file].progress.uploadStarted;
      });
      inProgressUpdatedFiles.forEach(function (file) {
        var updatedFile = _extends({}, updatedFiles[file], {
          isPaused: true
        });

        updatedFiles[file] = updatedFile;
      });
      this.setState({
        files: updatedFiles
      });
      this.emit('pause-all');
    };

    _proto.resumeAll = function resumeAll() {
      var updatedFiles = _extends({}, this.getState().files);

      var inProgressUpdatedFiles = Object.keys(updatedFiles).filter(function (file) {
        return !updatedFiles[file].progress.uploadComplete && updatedFiles[file].progress.uploadStarted;
      });
      inProgressUpdatedFiles.forEach(function (file) {
        var updatedFile = _extends({}, updatedFiles[file], {
          isPaused: false,
          error: null
        });

        updatedFiles[file] = updatedFile;
      });
      this.setState({
        files: updatedFiles
      });
      this.emit('resume-all');
    };

    _proto.retryAll = function retryAll() {
      var updatedFiles = _extends({}, this.getState().files);

      var filesToRetry = Object.keys(updatedFiles).filter(function (file) {
        return updatedFiles[file].error;
      });
      filesToRetry.forEach(function (file) {
        var updatedFile = _extends({}, updatedFiles[file], {
          isPaused: false,
          error: null
        });

        updatedFiles[file] = updatedFile;
      });
      this.setState({
        files: updatedFiles,
        error: null
      });
      this.emit('retry-all', filesToRetry);

      if (filesToRetry.length === 0) {
        return Promise.resolve({
          successful: [],
          failed: []
        });
      }

      var uploadID = this._createUpload(filesToRetry, {
        forceAllowNewUpload: true // create new upload even if allowNewUpload: false

      });

      return this._runUpload(uploadID);
    };

    _proto.cancelAll = function cancelAll() {
      this.emit('cancel-all');

      var _this$getState5 = this.getState(),
          files = _this$getState5.files;

      var fileIDs = Object.keys(files);

      if (fileIDs.length) {
        this.removeFiles(fileIDs, 'cancel-all');
      }

      this.setState({
        totalProgress: 0,
        error: null
      });
    };

    _proto.retryUpload = function retryUpload(fileID) {
      this.setFileState(fileID, {
        error: null,
        isPaused: false
      });
      this.emit('upload-retry', fileID);

      var uploadID = this._createUpload([fileID], {
        forceAllowNewUpload: true // create new upload even if allowNewUpload: false

      });

      return this._runUpload(uploadID);
    };

    _proto.reset = function reset() {
      this.cancelAll();
    };

    _proto._calculateProgress = function _calculateProgress(file, data) {
      if (!this.getFile(file.id)) {
        this.log("Not setting progress for a file that has been removed: " + file.id);
        return;
      } // bytesTotal may be null or zero; in that case we can't divide by it


      var canHavePercentage = isFinite(data.bytesTotal) && data.bytesTotal > 0;
      this.setFileState(file.id, {
        progress: _extends({}, this.getFile(file.id).progress, {
          bytesUploaded: data.bytesUploaded,
          bytesTotal: data.bytesTotal,
          percentage: canHavePercentage // TODO(goto-bus-stop) flooring this should probably be the choice of the UI?
          // we get more accurate calculations if we don't round this at all.
          ? Math.round(data.bytesUploaded / data.bytesTotal * 100) : 0
        })
      });

      this._calculateTotalProgress();
    };

    _proto._calculateTotalProgress = function _calculateTotalProgress() {
      // calculate total progress, using the number of files currently uploading,
      // multiplied by 100 and the summ of individual progress of each file
      var files = this.getFiles();
      var inProgress = files.filter(function (file) {
        return file.progress.uploadStarted || file.progress.preprocess || file.progress.postprocess;
      });

      if (inProgress.length === 0) {
        this.emit('progress', 0);
        this.setState({
          totalProgress: 0
        });
        return;
      }

      var sizedFiles = inProgress.filter(function (file) {
        return file.progress.bytesTotal != null;
      });
      var unsizedFiles = inProgress.filter(function (file) {
        return file.progress.bytesTotal == null;
      });

      if (sizedFiles.length === 0) {
        var progressMax = inProgress.length * 100;
        var currentProgress = unsizedFiles.reduce(function (acc, file) {
          return acc + file.progress.percentage;
        }, 0);

        var _totalProgress = Math.round(currentProgress / progressMax * 100);

        this.setState({
          totalProgress: _totalProgress
        });
        return;
      }

      var totalSize = sizedFiles.reduce(function (acc, file) {
        return acc + file.progress.bytesTotal;
      }, 0);
      var averageSize = totalSize / sizedFiles.length;
      totalSize += averageSize * unsizedFiles.length;
      var uploadedSize = 0;
      sizedFiles.forEach(function (file) {
        uploadedSize += file.progress.bytesUploaded;
      });
      unsizedFiles.forEach(function (file) {
        uploadedSize += averageSize * (file.progress.percentage || 0) / 100;
      });
      var totalProgress = totalSize === 0 ? 0 : Math.round(uploadedSize / totalSize * 100); // hot fix, because:
      // uploadedSize ended up larger than totalSize, resulting in 1325% total

      if (totalProgress > 100) {
        totalProgress = 100;
      }

      this.setState({
        totalProgress: totalProgress
      });
      this.emit('progress', totalProgress);
    }
    /**
     * Registers listeners for all global actions, like:
     * `error`, `file-removed`, `upload-progress`
     */
    ;

    _proto._addListeners = function _addListeners() {
      var _this6 = this;

      this.on('error', function (error) {
        var errorMsg = 'Unknown error';

        if (error.message) {
          errorMsg = error.message;
        }

        if (error.details) {
          errorMsg += ' ' + error.details;
        }

        _this6.setState({
          error: errorMsg
        });
      });
      this.on('upload-error', function (file, error, response) {
        var errorMsg = 'Unknown error';

        if (error.message) {
          errorMsg = error.message;
        }

        if (error.details) {
          errorMsg += ' ' + error.details;
        }

        _this6.setFileState(file.id, {
          error: errorMsg,
          response: response
        });

        _this6.setState({
          error: error.message
        });

        if (typeof error === 'object' && error.message) {
          var newError = new Error(error.message);
          newError.details = error.message;

          if (error.details) {
            newError.details += ' ' + error.details;
          }

          newError.message = _this6.i18n('failedToUpload', {
            file: file.name
          });

          _this6._showOrLogErrorAndThrow(newError, {
            throwErr: false
          });
        } else {
          _this6._showOrLogErrorAndThrow(error, {
            throwErr: false
          });
        }
      });
      this.on('upload', function () {
        _this6.setState({
          error: null
        });
      });
      this.on('upload-started', function (file, upload) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);

          return;
        }

        _this6.setFileState(file.id, {
          progress: {
            uploadStarted: Date.now(),
            uploadComplete: false,
            percentage: 0,
            bytesUploaded: 0,
            bytesTotal: file.size
          }
        });
      });
      this.on('upload-progress', this._calculateProgress);
      this.on('upload-success', function (file, uploadResp) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);

          return;
        }

        var currentProgress = _this6.getFile(file.id).progress;

        _this6.setFileState(file.id, {
          progress: _extends({}, currentProgress, {
            postprocess: _this6.postProcessors.length > 0 ? {
              mode: 'indeterminate'
            } : null,
            uploadComplete: true,
            percentage: 100,
            bytesUploaded: currentProgress.bytesTotal
          }),
          response: uploadResp,
          uploadURL: uploadResp.uploadURL,
          isPaused: false
        });

        _this6._calculateTotalProgress();
      });
      this.on('preprocess-progress', function (file, progress) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);

          return;
        }

        _this6.setFileState(file.id, {
          progress: _extends({}, _this6.getFile(file.id).progress, {
            preprocess: progress
          })
        });
      });
      this.on('preprocess-complete', function (file) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);

          return;
        }

        var files = _extends({}, _this6.getState().files);

        files[file.id] = _extends({}, files[file.id], {
          progress: _extends({}, files[file.id].progress)
        });
        delete files[file.id].progress.preprocess;

        _this6.setState({
          files: files
        });
      });
      this.on('postprocess-progress', function (file, progress) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);

          return;
        }

        _this6.setFileState(file.id, {
          progress: _extends({}, _this6.getState().files[file.id].progress, {
            postprocess: progress
          })
        });
      });
      this.on('postprocess-complete', function (file) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);

          return;
        }

        var files = _extends({}, _this6.getState().files);

        files[file.id] = _extends({}, files[file.id], {
          progress: _extends({}, files[file.id].progress)
        });
        delete files[file.id].progress.postprocess; // TODO should we set some kind of `fullyComplete` property on the file object
        // so it's easier to see that the file is upload…fully complete…rather than
        // what we have to do now (`uploadComplete && !postprocess`)

        _this6.setState({
          files: files
        });
      });
      this.on('restored', function () {
        // Files may have changed--ensure progress is still accurate.
        _this6._calculateTotalProgress();
      }); // show informer if offline

      if (typeof window !== 'undefined' && window.addEventListener) {
        window.addEventListener('online', function () {
          return _this6.updateOnlineStatus();
        });
        window.addEventListener('offline', function () {
          return _this6.updateOnlineStatus();
        });
        setTimeout(function () {
          return _this6.updateOnlineStatus();
        }, 3000);
      }
    };

    _proto.updateOnlineStatus = function updateOnlineStatus() {
      var online = typeof window.navigator.onLine !== 'undefined' ? window.navigator.onLine : true;

      if (!online) {
        this.emit('is-offline');
        this.info(this.i18n('noInternetConnection'), 'error', 0);
        this.wasOffline = true;
      } else {
        this.emit('is-online');

        if (this.wasOffline) {
          this.emit('back-online');
          this.info(this.i18n('connectedToInternet'), 'success', 3000);
          this.wasOffline = false;
        }
      }
    };

    _proto.getID = function getID() {
      return this.opts.id;
    }
    /**
     * Registers a plugin with Core.
     *
     * @param {object} Plugin object
     * @param {object} [opts] object with options to be passed to Plugin
     * @returns {object} self for chaining
     */
    ;

    _proto.use = function use(Plugin, opts) {
      if (typeof Plugin !== 'function') {
        var msg = "Expected a plugin class, but got " + (Plugin === null ? 'null' : typeof Plugin) + "." + ' Please verify that the plugin was imported and spelled correctly.';
        throw new TypeError(msg);
      } // Instantiate


      var plugin = new Plugin(this, opts);
      var pluginId = plugin.id;
      this.plugins[plugin.type] = this.plugins[plugin.type] || [];

      if (!pluginId) {
        throw new Error('Your plugin must have an id');
      }

      if (!plugin.type) {
        throw new Error('Your plugin must have a type');
      }

      var existsPluginAlready = this.getPlugin(pluginId);

      if (existsPluginAlready) {
        var _msg = "Already found a plugin named '" + existsPluginAlready.id + "'. " + ("Tried to use: '" + pluginId + "'.\n") + 'Uppy plugins must have unique `id` options. See https://uppy.io/docs/plugins/#id.';

        throw new Error(_msg);
      }

      if (Plugin.VERSION) {
        this.log("Using " + pluginId + " v" + Plugin.VERSION);
      }

      this.plugins[plugin.type].push(plugin);
      plugin.install();
      return this;
    }
    /**
     * Find one Plugin by name.
     *
     * @param {string} id plugin id
     * @returns {object|boolean}
     */
    ;

    _proto.getPlugin = function getPlugin(id) {
      var foundPlugin = null;
      this.iteratePlugins(function (plugin) {
        if (plugin.id === id) {
          foundPlugin = plugin;
          return false;
        }
      });
      return foundPlugin;
    }
    /**
     * Iterate through all `use`d plugins.
     *
     * @param {Function} method that will be run on each plugin
     */
    ;

    _proto.iteratePlugins = function iteratePlugins(method) {
      var _this7 = this;

      Object.keys(this.plugins).forEach(function (pluginType) {
        _this7.plugins[pluginType].forEach(method);
      });
    }
    /**
     * Uninstall and remove a plugin.
     *
     * @param {object} instance The plugin instance to remove.
     */
    ;

    _proto.removePlugin = function removePlugin(instance) {
      this.log("Removing plugin " + instance.id);
      this.emit('plugin-remove', instance);

      if (instance.uninstall) {
        instance.uninstall();
      }

      var list = this.plugins[instance.type].slice();
      var index = list.indexOf(instance);

      if (index !== -1) {
        list.splice(index, 1);
        this.plugins[instance.type] = list;
      }

      var updatedState = this.getState();
      delete updatedState.plugins[instance.id];
      this.setState(updatedState);
    }
    /**
     * Uninstall all plugins and close down this Uppy instance.
     */
    ;

    _proto.close = function close() {
      var _this8 = this;

      this.log("Closing Uppy instance " + this.opts.id + ": removing all files and uninstalling plugins");
      this.reset();

      this._storeUnsubscribe();

      this.iteratePlugins(function (plugin) {
        _this8.removePlugin(plugin);
      });
    }
    /**
     * Set info message in `state.info`, so that UI plugins like `Informer`
     * can display the message.
     *
     * @param {string | object} message Message to be displayed by the informer
     * @param {string} [type]
     * @param {number} [duration]
     */
    ;

    _proto.info = function info(message, type, duration) {
      if (type === void 0) {
        type = 'info';
      }

      if (duration === void 0) {
        duration = 3000;
      }

      var isComplexMessage = typeof message === 'object';
      this.setState({
        info: {
          isHidden: false,
          type: type,
          message: isComplexMessage ? message.message : message,
          details: isComplexMessage ? message.details : null
        }
      });
      this.emit('info-visible');
      clearTimeout(this.infoTimeoutID);

      if (duration === 0) {
        this.infoTimeoutID = undefined;
        return;
      } // hide the informer after `duration` milliseconds


      this.infoTimeoutID = setTimeout(this.hideInfo, duration);
    };

    _proto.hideInfo = function hideInfo() {
      var newInfo = _extends({}, this.getState().info, {
        isHidden: true
      });

      this.setState({
        info: newInfo
      });
      this.emit('info-hidden');
    }
    /**
     * Passes messages to a function, provided in `opts.logger`.
     * If `opts.logger: Uppy.debugLogger` or `opts.debug: true`, logs to the browser console.
     *
     * @param {string|object} message to log
     * @param {string} [type] optional `error` or `warning`
     */
    ;

    _proto.log = function log(message, type) {
      var logger = this.opts.logger;

      switch (type) {
        case 'error':
          logger.error(message);
          break;

        case 'warning':
          logger.warn(message);
          break;

        default:
          logger.debug(message);
          break;
      }
    }
    /**
     * Obsolete, event listeners are now added in the constructor.
     */
    ;

    _proto.run = function run() {
      this.log('Calling run() is no longer necessary.', 'warning');
      return this;
    }
    /**
     * Restore an upload by its ID.
     */
    ;

    _proto.restore = function restore(uploadID) {
      this.log("Core: attempting to restore upload \"" + uploadID + "\"");

      if (!this.getState().currentUploads[uploadID]) {
        this._removeUpload(uploadID);

        return Promise.reject(new Error('Nonexistent upload'));
      }

      return this._runUpload(uploadID);
    }
    /**
     * Create an upload for a bunch of files.
     *
     * @param {Array<string>} fileIDs File IDs to include in this upload.
     * @returns {string} ID of this upload.
     */
    ;

    _proto._createUpload = function _createUpload(fileIDs, opts) {
      var _extends4;

      if (opts === void 0) {
        opts = {};
      }

      var _opts = opts,
          _opts$forceAllowNewUp = _opts.forceAllowNewUpload,
          forceAllowNewUpload = _opts$forceAllowNewUp === void 0 ? false : _opts$forceAllowNewUp;

      var _this$getState6 = this.getState(),
          allowNewUpload = _this$getState6.allowNewUpload,
          currentUploads = _this$getState6.currentUploads;

      if (!allowNewUpload && !forceAllowNewUpload) {
        throw new Error('Cannot create a new upload: already uploading.');
      }

      var uploadID = cuid();
      this.emit('upload', {
        id: uploadID,
        fileIDs: fileIDs
      });
      this.setState({
        allowNewUpload: this.opts.allowMultipleUploads !== false,
        currentUploads: _extends({}, currentUploads, (_extends4 = {}, _extends4[uploadID] = {
          fileIDs: fileIDs,
          step: 0,
          result: {}
        }, _extends4))
      });
      return uploadID;
    };

    _proto._getUpload = function _getUpload(uploadID) {
      var _this$getState7 = this.getState(),
          currentUploads = _this$getState7.currentUploads;

      return currentUploads[uploadID];
    }
    /**
     * Add data to an upload's result object.
     *
     * @param {string} uploadID The ID of the upload.
     * @param {object} data Data properties to add to the result object.
     */
    ;

    _proto.addResultData = function addResultData(uploadID, data) {
      var _extends5;

      if (!this._getUpload(uploadID)) {
        this.log("Not setting result for an upload that has been removed: " + uploadID);
        return;
      }

      var currentUploads = this.getState().currentUploads;

      var currentUpload = _extends({}, currentUploads[uploadID], {
        result: _extends({}, currentUploads[uploadID].result, data)
      });

      this.setState({
        currentUploads: _extends({}, currentUploads, (_extends5 = {}, _extends5[uploadID] = currentUpload, _extends5))
      });
    }
    /**
     * Remove an upload, eg. if it has been canceled or completed.
     *
     * @param {string} uploadID The ID of the upload.
     */
    ;

    _proto._removeUpload = function _removeUpload(uploadID) {
      var currentUploads = _extends({}, this.getState().currentUploads);

      delete currentUploads[uploadID];
      this.setState({
        currentUploads: currentUploads
      });
    }
    /**
     * Run an upload. This picks up where it left off in case the upload is being restored.
     *
     * @private
     */
    ;

    _proto._runUpload = function _runUpload(uploadID) {
      var _this9 = this;

      var uploadData = this.getState().currentUploads[uploadID];
      var restoreStep = uploadData.step;
      var steps = [].concat(this.preProcessors, this.uploaders, this.postProcessors);
      var lastStep = Promise.resolve();
      steps.forEach(function (fn, step) {
        // Skip this step if we are restoring and have already completed this step before.
        if (step < restoreStep) {
          return;
        }

        lastStep = lastStep.then(function () {
          var _extends6;

          var _this9$getState = _this9.getState(),
              currentUploads = _this9$getState.currentUploads;

          var currentUpload = currentUploads[uploadID];

          if (!currentUpload) {
            return;
          }

          var updatedUpload = _extends({}, currentUpload, {
            step: step
          });

          _this9.setState({
            currentUploads: _extends({}, currentUploads, (_extends6 = {}, _extends6[uploadID] = updatedUpload, _extends6))
          }); // TODO give this the `updatedUpload` object as its only parameter maybe?
          // Otherwise when more metadata may be added to the upload this would keep getting more parameters


          return fn(updatedUpload.fileIDs, uploadID);
        }).then(function (result) {
          return null;
        });
      }); // Not returning the `catch`ed promise, because we still want to return a rejected
      // promise from this method if the upload failed.

      lastStep.catch(function (err) {
        _this9.emit('error', err, uploadID);

        _this9._removeUpload(uploadID);
      });
      return lastStep.then(function () {
        // Set result data.
        var _this9$getState2 = _this9.getState(),
            currentUploads = _this9$getState2.currentUploads;

        var currentUpload = currentUploads[uploadID];

        if (!currentUpload) {
          return;
        }

        var files = currentUpload.fileIDs.map(function (fileID) {
          return _this9.getFile(fileID);
        });
        var successful = files.filter(function (file) {
          return !file.error;
        });
        var failed = files.filter(function (file) {
          return file.error;
        });

        _this9.addResultData(uploadID, {
          successful: successful,
          failed: failed,
          uploadID: uploadID
        });
      }).then(function () {
        // Emit completion events.
        // This is in a separate function so that the `currentUploads` variable
        // always refers to the latest state. In the handler right above it refers
        // to an outdated object without the `.result` property.
        var _this9$getState3 = _this9.getState(),
            currentUploads = _this9$getState3.currentUploads;

        if (!currentUploads[uploadID]) {
          return;
        }

        var currentUpload = currentUploads[uploadID];
        var result = currentUpload.result;

        _this9.emit('complete', result);

        _this9._removeUpload(uploadID);

        return result;
      }).then(function (result) {
        if (result == null) {
          _this9.log("Not setting result for an upload that has been removed: " + uploadID);
        }

        return result;
      });
    }
    /**
     * Start an upload for all the files that are not currently being uploaded.
     *
     * @returns {Promise}
     */
    ;

    _proto.upload = function upload() {
      var _this10 = this;

      if (!this.plugins.uploader) {
        this.log('No uploader type plugins are used', 'warning');
      }

      var files = this.getState().files;
      var onBeforeUploadResult = this.opts.onBeforeUpload(files);

      if (onBeforeUploadResult === false) {
        return Promise.reject(new Error('Not starting the upload because onBeforeUpload returned false'));
      }

      if (onBeforeUploadResult && typeof onBeforeUploadResult === 'object') {
        files = onBeforeUploadResult; // Updating files in state, because uploader plugins receive file IDs,
        // and then fetch the actual file object from state

        this.setState({
          files: files
        });
      }

      return Promise.resolve().then(function () {
        return _this10._checkMinNumberOfFiles(files);
      }).catch(function (err) {
        _this10._showOrLogErrorAndThrow(err);
      }).then(function () {
        var _this10$getState = _this10.getState(),
            currentUploads = _this10$getState.currentUploads; // get a list of files that are currently assigned to uploads


        var currentlyUploadingFiles = Object.keys(currentUploads).reduce(function (prev, curr) {
          return prev.concat(currentUploads[curr].fileIDs);
        }, []);
        var waitingFileIDs = [];
        Object.keys(files).forEach(function (fileID) {
          var file = _this10.getFile(fileID); // if the file hasn't started uploading and hasn't already been assigned to an upload..


          if (!file.progress.uploadStarted && currentlyUploadingFiles.indexOf(fileID) === -1) {
            waitingFileIDs.push(file.id);
          }
        });

        var uploadID = _this10._createUpload(waitingFileIDs);

        return _this10._runUpload(uploadID);
      }).catch(function (err) {
        _this10._showOrLogErrorAndThrow(err, {
          showInformer: false
        });
      });
    };

    _createClass(Uppy, [{
      key: "state",
      get: function get() {
        return this.getState();
      }
    }]);

    return Uppy;
  }();

  Uppy.VERSION = "1.14.1";

  module.exports = function (opts) {
    return new Uppy(opts);
  }; // Expose class constructor.


  module.exports.Uppy = Uppy;
  module.exports.Plugin = Plugin;
  module.exports.debugLogger = debugLogger;
  },{"./Plugin":13,"./loggers":15,"./supportsUploadProgress":16,"@transloadit/prettier-bytes":2,"@uppy/store-default":17,"@uppy/utils/lib/Translator":23,"@uppy/utils/lib/generateFileID":28,"@uppy/utils/lib/getFileNameAndExtension":29,"@uppy/utils/lib/getFileType":30,"cuid":41,"lodash.throttle":46,"mime-match":48,"namespace-emitter":49}],15:[function(require,module,exports){
  var getTimeStamp = require('@uppy/utils/lib/getTimeStamp'); // Swallow all logs, except errors.
  // default if logger is not set or debug: false


  var justErrorsLogger = {
    debug: function debug() {},
    warn: function warn() {},
    error: function error() {
      var _console;

      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }

      return (_console = console).error.apply(_console, ["[Uppy] [" + getTimeStamp() + "]"].concat(args));
    }
  }; // Print logs to console with namespace + timestamp,
  // set by logger: Uppy.debugLogger or debug: true

  var debugLogger = {
    debug: function debug() {
      // IE 10 doesn’t support console.debug
      var debug = console.debug || console.log;

      for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
        args[_key2] = arguments[_key2];
      }

      debug.call.apply(debug, [console, "[Uppy] [" + getTimeStamp() + "]"].concat(args));
    },
    warn: function warn() {
      var _console2;

      for (var _len3 = arguments.length, args = new Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
        args[_key3] = arguments[_key3];
      }

      return (_console2 = console).warn.apply(_console2, ["[Uppy] [" + getTimeStamp() + "]"].concat(args));
    },
    error: function error() {
      var _console3;

      for (var _len4 = arguments.length, args = new Array(_len4), _key4 = 0; _key4 < _len4; _key4++) {
        args[_key4] = arguments[_key4];
      }

      return (_console3 = console).error.apply(_console3, ["[Uppy] [" + getTimeStamp() + "]"].concat(args));
    }
  };
  module.exports = {
    justErrorsLogger: justErrorsLogger,
    debugLogger: debugLogger
  };
  },{"@uppy/utils/lib/getTimeStamp":32}],16:[function(require,module,exports){
  // Edge 15.x does not fire 'progress' events on uploads.
  // See https://github.com/transloadit/uppy/issues/945
  // And https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/12224510/
  module.exports = function supportsUploadProgress(userAgent) {
    // Allow passing in userAgent for tests
    if (userAgent == null) {
      userAgent = typeof navigator !== 'undefined' ? navigator.userAgent : null;
    } // Assume it works because basically everything supports progress events.


    if (!userAgent) return true;
    var m = /Edge\/(\d+\.\d+)/.exec(userAgent);
    if (!m) return true;
    var edgeVersion = m[1];

    var _edgeVersion$split = edgeVersion.split('.'),
        major = _edgeVersion$split[0],
        minor = _edgeVersion$split[1];

    major = parseInt(major, 10);
    minor = parseInt(minor, 10); // Worked before:
    // Edge 40.15063.0.0
    // Microsoft EdgeHTML 15.15063

    if (major < 15 || major === 15 && minor < 15063) {
      return true;
    } // Fixed in:
    // Microsoft EdgeHTML 18.18218


    if (major > 18 || major === 18 && minor >= 18218) {
      return true;
    } // other versions don't work.


    return false;
  };
  },{}],17:[function(require,module,exports){
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  /**
   * Default store that keeps state in a simple object.
   */
  var DefaultStore = /*#__PURE__*/function () {
    function DefaultStore() {
      this.state = {};
      this.callbacks = [];
    }

    var _proto = DefaultStore.prototype;

    _proto.getState = function getState() {
      return this.state;
    };

    _proto.setState = function setState(patch) {
      var prevState = _extends({}, this.state);

      var nextState = _extends({}, this.state, patch);

      this.state = nextState;

      this._publish(prevState, nextState, patch);
    };

    _proto.subscribe = function subscribe(listener) {
      var _this = this;

      this.callbacks.push(listener);
      return function () {
        // Remove the listener.
        _this.callbacks.splice(_this.callbacks.indexOf(listener), 1);
      };
    };

    _proto._publish = function _publish() {
      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }

      this.callbacks.forEach(function (listener) {
        listener.apply(void 0, args);
      });
    };

    return DefaultStore;
  }();

  DefaultStore.VERSION = "1.2.4";

  module.exports = function defaultStore() {
    return new DefaultStore();
  };
  },{}],18:[function(require,module,exports){
  var _class, _temp;

  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

  var _require = require('@uppy/core'),
      Plugin = _require.Plugin;

  var Translator = require('@uppy/utils/lib/Translator');

  var dataURItoBlob = require('@uppy/utils/lib/dataURItoBlob');

  var isObjectURL = require('@uppy/utils/lib/isObjectURL');

  var isPreviewSupported = require('@uppy/utils/lib/isPreviewSupported');

  var MathLog2 = require('math-log2'); // Polyfill for IE.


  var exifr = require('exifr/dist/mini.legacy.umd.js');
  /**
   * The Thumbnail Generator plugin
   */


  module.exports = (_temp = _class = /*#__PURE__*/function (_Plugin) {
    _inheritsLoose(ThumbnailGenerator, _Plugin);

    function ThumbnailGenerator(uppy, opts) {
      var _this;

      _this = _Plugin.call(this, uppy, opts) || this;

      _this.onFileAdded = function (file) {
        if (!file.preview && isPreviewSupported(file.type) && !file.isRemote) {
          _this.addToQueue(file.id);
        }
      };

      _this.onCancelRequest = function (file) {
        var index = _this.queue.indexOf(file.id);

        if (index !== -1) {
          _this.queue.splice(index, 1);
        }
      };

      _this.onFileRemoved = function (file) {
        var index = _this.queue.indexOf(file.id);

        if (index !== -1) {
          _this.queue.splice(index, 1);
        } // Clean up object URLs.


        if (file.preview && isObjectURL(file.preview)) {
          URL.revokeObjectURL(file.preview);
        }
      };

      _this.onRestored = function () {
        var _this$uppy$getState = _this.uppy.getState(),
            files = _this$uppy$getState.files;

        var fileIDs = Object.keys(files);
        fileIDs.forEach(function (fileID) {
          var file = _this.uppy.getFile(fileID);

          if (!file.isRestored) return; // Only add blob URLs; they are likely invalid after being restored.

          if (!file.preview || isObjectURL(file.preview)) {
            _this.addToQueue(file.id);
          }
        });
      };

      _this.waitUntilAllProcessed = function (fileIDs) {
        fileIDs.forEach(function (fileID) {
          var file = _this.uppy.getFile(fileID);

          _this.uppy.emit('preprocess-progress', file, {
            mode: 'indeterminate',
            message: _this.i18n('generatingThumbnails')
          });
        });

        var emitPreprocessCompleteForAll = function emitPreprocessCompleteForAll() {
          fileIDs.forEach(function (fileID) {
            var file = _this.uppy.getFile(fileID);

            _this.uppy.emit('preprocess-complete', file);
          });
        };

        return new Promise(function (resolve, reject) {
          if (_this.queueProcessing) {
            _this.uppy.once('thumbnail:all-generated', function () {
              emitPreprocessCompleteForAll();
              resolve();
            });
          } else {
            emitPreprocessCompleteForAll();
            resolve();
          }
        });
      };

      _this.type = 'modifier';
      _this.id = _this.opts.id || 'ThumbnailGenerator';
      _this.title = 'Thumbnail Generator';
      _this.queue = [];
      _this.queueProcessing = false;
      _this.defaultThumbnailDimension = 200;
      _this.thumbnailType = _this.opts.thumbnailType || 'image/jpeg';
      _this.defaultLocale = {
        strings: {
          generatingThumbnails: 'Generating thumbnails...'
        }
      };
      var defaultOptions = {
        thumbnailWidth: null,
        thumbnailHeight: null,
        waitForThumbnailsBeforeUpload: false,
        lazy: false
      };
      _this.opts = _extends({}, defaultOptions, opts);

      if (_this.opts.lazy && _this.opts.waitForThumbnailsBeforeUpload) {
        throw new Error('ThumbnailGenerator: The `lazy` and `waitForThumbnailsBeforeUpload` options are mutually exclusive. Please ensure at most one of them is set to `true`.');
      }

      _this.i18nInit();

      return _this;
    }

    var _proto = ThumbnailGenerator.prototype;

    _proto.setOptions = function setOptions(newOpts) {
      _Plugin.prototype.setOptions.call(this, newOpts);

      this.i18nInit();
    };

    _proto.i18nInit = function i18nInit() {
      this.translator = new Translator([this.defaultLocale, this.uppy.locale, this.opts.locale]);
      this.i18n = this.translator.translate.bind(this.translator);
      this.setPluginState(); // so that UI re-renders and we see the updated locale
    }
    /**
     * Create a thumbnail for the given Uppy file object.
     *
     * @param {{data: Blob}} file
     * @param {number} targetWidth
     * @param {number} targetHeight
     * @returns {Promise}
     */
    ;

    _proto.createThumbnail = function createThumbnail(file, targetWidth, targetHeight) {
      var _this2 = this;

      // bug in the compatibility data
      // eslint-disable-next-line compat/compat
      var originalUrl = URL.createObjectURL(file.data);
      var onload = new Promise(function (resolve, reject) {
        var image = new Image();
        image.src = originalUrl;
        image.addEventListener('load', function () {
          // bug in the compatibility data
          // eslint-disable-next-line compat/compat
          URL.revokeObjectURL(originalUrl);
          resolve(image);
        });
        image.addEventListener('error', function (event) {
          // bug in the compatibility data
          // eslint-disable-next-line compat/compat
          URL.revokeObjectURL(originalUrl);
          reject(event.error || new Error('Could not create thumbnail'));
        });
      });
      var orientationPromise = exifr.rotation(file.data).catch(function (_err) {
        return 1;
      });
      return Promise.all([onload, orientationPromise]).then(function (_ref) {
        var image = _ref[0],
            orientation = _ref[1];

        var dimensions = _this2.getProportionalDimensions(image, targetWidth, targetHeight, orientation.deg);

        var rotatedImage = _this2.rotateImage(image, orientation);

        var resizedImage = _this2.resizeImage(rotatedImage, dimensions.width, dimensions.height);

        return _this2.canvasToBlob(resizedImage, _this2.thumbnailType, 80);
      }).then(function (blob) {
        // bug in the compatibility data
        // eslint-disable-next-line compat/compat
        return URL.createObjectURL(blob);
      });
    }
    /**
     * Get the new calculated dimensions for the given image and a target width
     * or height. If both width and height are given, only width is taken into
     * account. If neither width nor height are given, the default dimension
     * is used.
     */
    ;

    _proto.getProportionalDimensions = function getProportionalDimensions(img, width, height, rotation) {
      var aspect = img.width / img.height;

      if (rotation === 90 || rotation === 270) {
        aspect = img.height / img.width;
      }

      if (width != null) {
        return {
          width: width,
          height: Math.round(width / aspect)
        };
      }

      if (height != null) {
        return {
          width: Math.round(height * aspect),
          height: height
        };
      }

      return {
        width: this.defaultThumbnailDimension,
        height: Math.round(this.defaultThumbnailDimension / aspect)
      };
    }
    /**
     * Make sure the image doesn’t exceed browser/device canvas limits.
     * For ios with 256 RAM and ie
     */
    ;

    _proto.protect = function protect(image) {
      // https://stackoverflow.com/questions/6081483/maximum-size-of-a-canvas-element
      var ratio = image.width / image.height;
      var maxSquare = 5000000; // ios max canvas square

      var maxSize = 4096; // ie max canvas dimensions

      var maxW = Math.floor(Math.sqrt(maxSquare * ratio));
      var maxH = Math.floor(maxSquare / Math.sqrt(maxSquare * ratio));

      if (maxW > maxSize) {
        maxW = maxSize;
        maxH = Math.round(maxW / ratio);
      }

      if (maxH > maxSize) {
        maxH = maxSize;
        maxW = Math.round(ratio * maxH);
      }

      if (image.width > maxW) {
        var canvas = document.createElement('canvas');
        canvas.width = maxW;
        canvas.height = maxH;
        canvas.getContext('2d').drawImage(image, 0, 0, maxW, maxH);
        image = canvas;
      }

      return image;
    }
    /**
     * Resize an image to the target `width` and `height`.
     *
     * Returns a Canvas with the resized image on it.
     */
    ;

    _proto.resizeImage = function resizeImage(image, targetWidth, targetHeight) {
      // Resizing in steps refactored to use a solution from
      // https://blog.uploadcare.com/image-resize-in-browsers-is-broken-e38eed08df01
      image = this.protect(image);
      var steps = Math.ceil(MathLog2(image.width / targetWidth));

      if (steps < 1) {
        steps = 1;
      }

      var sW = targetWidth * Math.pow(2, steps - 1);
      var sH = targetHeight * Math.pow(2, steps - 1);
      var x = 2;

      while (steps--) {
        var canvas = document.createElement('canvas');
        canvas.width = sW;
        canvas.height = sH;
        canvas.getContext('2d').drawImage(image, 0, 0, sW, sH);
        image = canvas;
        sW = Math.round(sW / x);
        sH = Math.round(sH / x);
      }

      return image;
    };

    _proto.rotateImage = function rotateImage(image, translate) {
      var w = image.width;
      var h = image.height;

      if (translate.deg === 90 || translate.deg === 270) {
        w = image.height;
        h = image.width;
      }

      var canvas = document.createElement('canvas');
      canvas.width = w;
      canvas.height = h;
      var context = canvas.getContext('2d');
      context.translate(w / 2, h / 2);

      if (translate.canvas) {
        context.rotate(translate.rad);
        context.scale(translate.scaleX, translate.scaleY);
      }

      context.drawImage(image, -image.width / 2, -image.height / 2, image.width, image.height);
      return canvas;
    }
    /**
     * Save a <canvas> element's content to a Blob object.
     *
     * @param {HTMLCanvasElement} canvas
     * @returns {Promise}
     */
    ;

    _proto.canvasToBlob = function canvasToBlob(canvas, type, quality) {
      try {
        canvas.getContext('2d').getImageData(0, 0, 1, 1);
      } catch (err) {
        if (err.code === 18) {
          return Promise.reject(new Error('cannot read image, probably an svg with external resources'));
        }
      }

      if (canvas.toBlob) {
        return new Promise(function (resolve) {
          canvas.toBlob(resolve, type, quality);
        }).then(function (blob) {
          if (blob === null) {
            throw new Error('cannot read image, probably an svg with external resources');
          }

          return blob;
        });
      }

      return Promise.resolve().then(function () {
        return dataURItoBlob(canvas.toDataURL(type, quality), {});
      }).then(function (blob) {
        if (blob === null) {
          throw new Error('could not extract blob, probably an old browser');
        }

        return blob;
      });
    }
    /**
     * Set the preview URL for a file.
     */
    ;

    _proto.setPreviewURL = function setPreviewURL(fileID, preview) {
      this.uppy.setFileState(fileID, {
        preview: preview
      });
    };

    _proto.addToQueue = function addToQueue(item) {
      this.queue.push(item);

      if (this.queueProcessing === false) {
        this.processQueue();
      }
    };

    _proto.processQueue = function processQueue() {
      var _this3 = this;

      this.queueProcessing = true;

      if (this.queue.length > 0) {
        var current = this.uppy.getFile(this.queue.shift());

        if (!current) {
          this.uppy.log('[ThumbnailGenerator] file was removed before a thumbnail could be generated, but not removed from the queue. This is probably a bug', 'error');
          return;
        }

        return this.requestThumbnail(current).catch(function (err) {}) // eslint-disable-line handle-callback-err
        .then(function () {
          return _this3.processQueue();
        });
      } else {
        this.queueProcessing = false;
        this.uppy.log('[ThumbnailGenerator] Emptied thumbnail queue');
        this.uppy.emit('thumbnail:all-generated');
      }
    };

    _proto.requestThumbnail = function requestThumbnail(file) {
      var _this4 = this;

      if (isPreviewSupported(file.type) && !file.isRemote) {
        return this.createThumbnail(file, this.opts.thumbnailWidth, this.opts.thumbnailHeight).then(function (preview) {
          _this4.setPreviewURL(file.id, preview);

          _this4.uppy.log("[ThumbnailGenerator] Generated thumbnail for " + file.id);

          _this4.uppy.emit('thumbnail:generated', _this4.uppy.getFile(file.id), preview);
        }).catch(function (err) {
          _this4.uppy.log("[ThumbnailGenerator] Failed thumbnail for " + file.id + ":", 'warning');

          _this4.uppy.log(err, 'warning');

          _this4.uppy.emit('thumbnail:error', _this4.uppy.getFile(file.id), err);
        });
      }

      return Promise.resolve();
    };

    _proto.install = function install() {
      this.uppy.on('file-removed', this.onFileRemoved);

      if (this.opts.lazy) {
        this.uppy.on('thumbnail:request', this.onFileAdded);
        this.uppy.on('thumbnail:cancel', this.onCancelRequest);
      } else {
        this.uppy.on('file-added', this.onFileAdded);
        this.uppy.on('restored', this.onRestored);
      }

      if (this.opts.waitForThumbnailsBeforeUpload) {
        this.uppy.addPreProcessor(this.waitUntilAllProcessed);
      }
    };

    _proto.uninstall = function uninstall() {
      this.uppy.off('file-removed', this.onFileRemoved);

      if (this.opts.lazy) {
        this.uppy.off('thumbnail:request', this.onFileAdded);
        this.uppy.off('thumbnail:cancel', this.onCancelRequest);
      } else {
        this.uppy.off('file-added', this.onFileAdded);
        this.uppy.off('restored', this.onRestored);
      }

      if (this.opts.waitForThumbnailsBeforeUpload) {
        this.uppy.removePreProcessor(this.waitUntilAllProcessed);
      }
    };

    return ThumbnailGenerator;
  }(Plugin), _class.VERSION = "1.7.1", _temp);
  },{"@uppy/core":14,"@uppy/utils/lib/Translator":23,"@uppy/utils/lib/dataURItoBlob":24,"@uppy/utils/lib/isObjectURL":36,"@uppy/utils/lib/isPreviewSupported":37,"exifr/dist/mini.legacy.umd.js":45,"math-log2":47}],19:[function(require,module,exports){
  /**
   * Create a wrapper around an event emitter with a `remove` method to remove
   * all events that were added using the wrapped emitter.
   */
  module.exports = /*#__PURE__*/function () {
    function EventTracker(emitter) {
      this._events = [];
      this._emitter = emitter;
    }

    var _proto = EventTracker.prototype;

    _proto.on = function on(event, fn) {
      this._events.push([event, fn]);

      return this._emitter.on(event, fn);
    };

    _proto.remove = function remove() {
      var _this = this;

      this._events.forEach(function (_ref) {
        var event = _ref[0],
            fn = _ref[1];

        _this._emitter.off(event, fn);
      });
    };

    return EventTracker;
  }();
  },{}],20:[function(require,module,exports){
  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

  function _wrapNativeSuper(Class) { var _cache = typeof Map === "function" ? new Map() : undefined; _wrapNativeSuper = function _wrapNativeSuper(Class) { if (Class === null || !_isNativeFunction(Class)) return Class; if (typeof Class !== "function") { throw new TypeError("Super expression must either be null or a function"); } if (typeof _cache !== "undefined") { if (_cache.has(Class)) return _cache.get(Class); _cache.set(Class, Wrapper); } function Wrapper() { return _construct(Class, arguments, _getPrototypeOf(this).constructor); } Wrapper.prototype = Object.create(Class.prototype, { constructor: { value: Wrapper, enumerable: false, writable: true, configurable: true } }); return _setPrototypeOf(Wrapper, Class); }; return _wrapNativeSuper(Class); }

  function _construct(Parent, args, Class) { if (_isNativeReflectConstruct()) { _construct = Reflect.construct; } else { _construct = function _construct(Parent, args, Class) { var a = [null]; a.push.apply(a, args); var Constructor = Function.bind.apply(Parent, a); var instance = new Constructor(); if (Class) _setPrototypeOf(instance, Class.prototype); return instance; }; } return _construct.apply(null, arguments); }

  function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }

  function _isNativeFunction(fn) { return Function.toString.call(fn).indexOf("[native code]") !== -1; }

  function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }

  function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

  var NetworkError = /*#__PURE__*/function (_Error) {
    _inheritsLoose(NetworkError, _Error);

    function NetworkError(error, xhr) {
      var _this;

      if (xhr === void 0) {
        xhr = null;
      }

      _this = _Error.call(this, "This looks like a network error, the endpoint might be blocked by an internet provider or a firewall.\n\nSource error: [" + error + "]") || this;
      _this.isNetworkError = true;
      _this.request = xhr;
      return _this;
    }

    return NetworkError;
  }( /*#__PURE__*/_wrapNativeSuper(Error));

  module.exports = NetworkError;
  },{}],21:[function(require,module,exports){
  /**
   * Helper to abort upload requests if there has not been any progress for `timeout` ms.
   * Create an instance using `timer = new ProgressTimeout(10000, onTimeout)`
   * Call `timer.progress()` to signal that there has been progress of any kind.
   * Call `timer.done()` when the upload has completed.
   */
  var ProgressTimeout = /*#__PURE__*/function () {
    function ProgressTimeout(timeout, timeoutHandler) {
      this._timeout = timeout;
      this._onTimedOut = timeoutHandler;
      this._isDone = false;
      this._aliveTimer = null;
      this._onTimedOut = this._onTimedOut.bind(this);
    }

    var _proto = ProgressTimeout.prototype;

    _proto.progress = function progress() {
      // Some browsers fire another progress event when the upload is
      // cancelled, so we have to ignore progress after the timer was
      // told to stop.
      if (this._isDone) return;

      if (this._timeout > 0) {
        if (this._aliveTimer) clearTimeout(this._aliveTimer);
        this._aliveTimer = setTimeout(this._onTimedOut, this._timeout);
      }
    };

    _proto.done = function done() {
      if (this._aliveTimer) {
        clearTimeout(this._aliveTimer);
        this._aliveTimer = null;
      }

      this._isDone = true;
    };

    return ProgressTimeout;
  }();

  module.exports = ProgressTimeout;
  },{}],22:[function(require,module,exports){
  /**
   * Array.prototype.findIndex ponyfill for old browsers.
   */
  function findIndex(array, predicate) {
    for (var i = 0; i < array.length; i++) {
      if (predicate(array[i])) return i;
    }

    return -1;
  }

  function createCancelError() {
    return new Error('Cancelled');
  }

  module.exports = /*#__PURE__*/function () {
    function RateLimitedQueue(limit) {
      if (typeof limit !== 'number' || limit === 0) {
        this.limit = Infinity;
      } else {
        this.limit = limit;
      }

      this.activeRequests = 0;
      this.queuedHandlers = [];
    }

    var _proto = RateLimitedQueue.prototype;

    _proto._call = function _call(fn) {
      var _this = this;

      this.activeRequests += 1;
      var _done = false;
      var cancelActive;

      try {
        cancelActive = fn();
      } catch (err) {
        this.activeRequests -= 1;
        throw err;
      }

      return {
        abort: function abort() {
          if (_done) return;
          _done = true;
          _this.activeRequests -= 1;
          cancelActive();

          _this._queueNext();
        },
        done: function done() {
          if (_done) return;
          _done = true;
          _this.activeRequests -= 1;

          _this._queueNext();
        }
      };
    };

    _proto._queueNext = function _queueNext() {
      var _this2 = this;

      // Do it soon but not immediately, this allows clearing out the entire queue synchronously
      // one by one without continuously _advancing_ it (and starting new tasks before immediately
      // aborting them)
      Promise.resolve().then(function () {
        _this2._next();
      });
    };

    _proto._next = function _next() {
      if (this.activeRequests >= this.limit) {
        return;
      }

      if (this.queuedHandlers.length === 0) {
        return;
      } // Dispatch the next request, and update the abort/done handlers
      // so that cancelling it does the Right Thing (and doesn't just try
      // to dequeue an already-running request).


      var next = this.queuedHandlers.shift();

      var handler = this._call(next.fn);

      next.abort = handler.abort;
      next.done = handler.done;
    };

    _proto._queue = function _queue(fn, options) {
      var _this3 = this;

      if (options === void 0) {
        options = {};
      }

      var handler = {
        fn: fn,
        priority: options.priority || 0,
        abort: function abort() {
          _this3._dequeue(handler);
        },
        done: function done() {
          throw new Error('Cannot mark a queued request as done: this indicates a bug');
        }
      };
      var index = findIndex(this.queuedHandlers, function (other) {
        return handler.priority > other.priority;
      });

      if (index === -1) {
        this.queuedHandlers.push(handler);
      } else {
        this.queuedHandlers.splice(index, 0, handler);
      }

      return handler;
    };

    _proto._dequeue = function _dequeue(handler) {
      var index = this.queuedHandlers.indexOf(handler);

      if (index !== -1) {
        this.queuedHandlers.splice(index, 1);
      }
    };

    _proto.run = function run(fn, queueOptions) {
      if (this.activeRequests < this.limit) {
        return this._call(fn);
      }

      return this._queue(fn, queueOptions);
    };

    _proto.wrapPromiseFunction = function wrapPromiseFunction(fn, queueOptions) {
      var _this4 = this;

      return function () {
        for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
          args[_key] = arguments[_key];
        }

        var queuedRequest;
        var outerPromise = new Promise(function (resolve, reject) {
          queuedRequest = _this4.run(function () {
            var cancelError;
            var innerPromise;

            try {
              innerPromise = Promise.resolve(fn.apply(void 0, args));
            } catch (err) {
              innerPromise = Promise.reject(err);
            }

            innerPromise.then(function (result) {
              if (cancelError) {
                reject(cancelError);
              } else {
                queuedRequest.done();
                resolve(result);
              }
            }, function (err) {
              if (cancelError) {
                reject(cancelError);
              } else {
                queuedRequest.done();
                reject(err);
              }
            });
            return function () {
              cancelError = createCancelError();
            };
          }, queueOptions);
        });

        outerPromise.abort = function () {
          queuedRequest.abort();
        };

        return outerPromise;
      };
    };

    return RateLimitedQueue;
  }();
  },{}],23:[function(require,module,exports){
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  var has = require('./hasProperty');
  /**
   * Translates strings with interpolation & pluralization support.
   * Extensible with custom dictionaries and pluralization functions.
   *
   * Borrows heavily from and inspired by Polyglot https://github.com/airbnb/polyglot.js,
   * basically a stripped-down version of it. Differences: pluralization functions are not hardcoded
   * and can be easily added among with dictionaries, nested objects are used for pluralization
   * as opposed to `||||` delimeter
   *
   * Usage example: `translator.translate('files_chosen', {smart_count: 3})`
   */


  module.exports = /*#__PURE__*/function () {
    /**
     * @param {object|Array<object>} locales - locale or list of locales.
     */
    function Translator(locales) {
      var _this = this;

      this.locale = {
        strings: {},
        pluralize: function pluralize(n) {
          if (n === 1) {
            return 0;
          }

          return 1;
        }
      };

      if (Array.isArray(locales)) {
        locales.forEach(function (locale) {
          return _this._apply(locale);
        });
      } else {
        this._apply(locales);
      }
    }

    var _proto = Translator.prototype;

    _proto._apply = function _apply(locale) {
      if (!locale || !locale.strings) {
        return;
      }

      var prevLocale = this.locale;
      this.locale = _extends({}, prevLocale, {
        strings: _extends({}, prevLocale.strings, locale.strings)
      });
      this.locale.pluralize = locale.pluralize || prevLocale.pluralize;
    }
    /**
     * Takes a string with placeholder variables like `%{smart_count} file selected`
     * and replaces it with values from options `{smart_count: 5}`
     *
     * @license https://github.com/airbnb/polyglot.js/blob/master/LICENSE
     * taken from https://github.com/airbnb/polyglot.js/blob/master/lib/polyglot.js#L299
     *
     * @param {string} phrase that needs interpolation, with placeholders
     * @param {object} options with values that will be used to replace placeholders
     * @returns {string} interpolated
     */
    ;

    _proto.interpolate = function interpolate(phrase, options) {
      var _String$prototype = String.prototype,
          split = _String$prototype.split,
          replace = _String$prototype.replace;
      var dollarRegex = /\$/g;
      var dollarBillsYall = '$$$$';
      var interpolated = [phrase];

      for (var arg in options) {
        if (arg !== '_' && has(options, arg)) {
          // Ensure replacement value is escaped to prevent special $-prefixed
          // regex replace tokens. the "$$$$" is needed because each "$" needs to
          // be escaped with "$" itself, and we need two in the resulting output.
          var replacement = options[arg];

          if (typeof replacement === 'string') {
            replacement = replace.call(options[arg], dollarRegex, dollarBillsYall);
          } // We create a new `RegExp` each time instead of using a more-efficient
          // string replace so that the same argument can be replaced multiple times
          // in the same phrase.


          interpolated = insertReplacement(interpolated, new RegExp('%\\{' + arg + '\\}', 'g'), replacement);
        }
      }

      return interpolated;

      function insertReplacement(source, rx, replacement) {
        var newParts = [];
        source.forEach(function (chunk) {
          // When the source contains multiple placeholders for interpolation,
          // we should ignore chunks that are not strings, because those
          // can be JSX objects and will be otherwise incorrectly turned into strings.
          // Without this condition we’d get this: [object Object] hello [object Object] my <button>
          if (typeof chunk !== 'string') {
            return newParts.push(chunk);
          }

          split.call(chunk, rx).forEach(function (raw, i, list) {
            if (raw !== '') {
              newParts.push(raw);
            } // Interlace with the `replacement` value


            if (i < list.length - 1) {
              newParts.push(replacement);
            }
          });
        });
        return newParts;
      }
    }
    /**
     * Public translate method
     *
     * @param {string} key
     * @param {object} options with values that will be used later to replace placeholders in string
     * @returns {string} translated (and interpolated)
     */
    ;

    _proto.translate = function translate(key, options) {
      return this.translateArray(key, options).join('');
    }
    /**
     * Get a translation and return the translated and interpolated parts as an array.
     *
     * @param {string} key
     * @param {object} options with values that will be used to replace placeholders
     * @returns {Array} The translated and interpolated parts, in order.
     */
    ;

    _proto.translateArray = function translateArray(key, options) {
      if (!has(this.locale.strings, key)) {
        throw new Error("missing string: " + key);
      }

      var string = this.locale.strings[key];
      var hasPluralForms = typeof string === 'object';

      if (hasPluralForms) {
        if (options && typeof options.smart_count !== 'undefined') {
          var plural = this.locale.pluralize(options.smart_count);
          return this.interpolate(string[plural], options);
        } else {
          throw new Error('Attempted to use a string with plural forms, but no value was given for %{smart_count}');
        }
      }

      return this.interpolate(string, options);
    };

    return Translator;
  }();
  },{"./hasProperty":33}],24:[function(require,module,exports){
  module.exports = function dataURItoBlob(dataURI, opts, toFile) {
    // get the base64 data
    var data = dataURI.split(',')[1]; // user may provide mime type, if not get it from data URI

    var mimeType = opts.mimeType || dataURI.split(',')[0].split(':')[1].split(';')[0]; // default to plain/text if data URI has no mimeType

    if (mimeType == null) {
      mimeType = 'plain/text';
    }

    var binary = atob(data);
    var array = [];

    for (var i = 0; i < binary.length; i++) {
      array.push(binary.charCodeAt(i));
    }

    var bytes;

    try {
      bytes = new Uint8Array(array); // eslint-disable-line compat/compat
    } catch (err) {
      return null;
    } // Convert to a File?


    if (toFile) {
      return new File([bytes], opts.name || '', {
        type: mimeType
      });
    }

    return new Blob([bytes], {
      type: mimeType
    });
  };
  },{}],25:[function(require,module,exports){
  var throttle = require('lodash.throttle');

  function _emitSocketProgress(uploader, progressData, file) {
    var progress = progressData.progress,
        bytesUploaded = progressData.bytesUploaded,
        bytesTotal = progressData.bytesTotal;

    if (progress) {
      uploader.uppy.log("Upload progress: " + progress);
      uploader.uppy.emit('upload-progress', file, {
        uploader: uploader,
        bytesUploaded: bytesUploaded,
        bytesTotal: bytesTotal
      });
    }
  }

  module.exports = throttle(_emitSocketProgress, 300, {
    leading: true,
    trailing: true
  });
  },{"lodash.throttle":46}],26:[function(require,module,exports){
  var NetworkError = require('@uppy/utils/lib/NetworkError');
  /**
   * Wrapper around window.fetch that throws a NetworkError when appropriate
   */


  module.exports = function fetchWithNetworkError() {
    return fetch.apply(void 0, arguments).catch(function (err) {
      if (err.name === 'AbortError') {
        throw err;
      } else {
        throw new NetworkError(err);
      }
    });
  };
  },{"@uppy/utils/lib/NetworkError":20}],27:[function(require,module,exports){
  var isDOMElement = require('./isDOMElement');
  /**
   * Find a DOM element.
   *
   * @param {Node|string} element
   * @returns {Node|null}
   */


  module.exports = function findDOMElement(element, context) {
    if (context === void 0) {
      context = document;
    }

    if (typeof element === 'string') {
      return context.querySelector(element);
    }

    if (isDOMElement(element)) {
      return element;
    }
  };
  },{"./isDOMElement":34}],28:[function(require,module,exports){
  /**
   * Takes a file object and turns it into fileID, by converting file.name to lowercase,
   * removing extra characters and adding type, size and lastModified
   *
   * @param {object} file
   * @returns {string} the fileID
   */
  module.exports = function generateFileID(file) {
    // It's tempting to do `[items].filter(Boolean).join('-')` here, but that
    // is slower! simple string concatenation is fast
    var id = 'uppy';

    if (typeof file.name === 'string') {
      id += '-' + encodeFilename(file.name.toLowerCase());
    }

    if (file.type !== undefined) {
      id += '-' + file.type;
    }

    if (file.meta && typeof file.meta.relativePath === 'string') {
      id += '-' + encodeFilename(file.meta.relativePath.toLowerCase());
    }

    if (file.data.size !== undefined) {
      id += '-' + file.data.size;
    }

    if (file.data.lastModified !== undefined) {
      id += '-' + file.data.lastModified;
    }

    return id;
  };

  function encodeFilename(name) {
    var suffix = '';
    return name.replace(/[^A-Z0-9]/ig, function (character) {
      suffix += '-' + encodeCharacter(character);
      return '/';
    }) + suffix;
  }

  function encodeCharacter(character) {
    return character.charCodeAt(0).toString(32);
  }
  },{}],29:[function(require,module,exports){
  /**
   * Takes a full filename string and returns an object {name, extension}
   *
   * @param {string} fullFileName
   * @returns {object} {name, extension}
   */
  module.exports = function getFileNameAndExtension(fullFileName) {
    var lastDot = fullFileName.lastIndexOf('.'); // these count as no extension: "no-dot", "trailing-dot."

    if (lastDot === -1 || lastDot === fullFileName.length - 1) {
      return {
        name: fullFileName,
        extension: undefined
      };
    } else {
      return {
        name: fullFileName.slice(0, lastDot),
        extension: fullFileName.slice(lastDot + 1)
      };
    }
  };
  },{}],30:[function(require,module,exports){
  var getFileNameAndExtension = require('./getFileNameAndExtension');

  var mimeTypes = require('./mimeTypes');

  module.exports = function getFileType(file) {
    var fileExtension = file.name ? getFileNameAndExtension(file.name).extension : null;
    fileExtension = fileExtension ? fileExtension.toLowerCase() : null;

    if (file.type) {
      // if mime type is set in the file object already, use that
      return file.type;
    } else if (fileExtension && mimeTypes[fileExtension]) {
      // else, see if we can map extension to a mime type
      return mimeTypes[fileExtension];
    } else {
      // if all fails, fall back to a generic byte stream type
      return 'application/octet-stream';
    }
  };
  },{"./getFileNameAndExtension":29,"./mimeTypes":38}],31:[function(require,module,exports){
  module.exports = function getSocketHost(url) {
    // get the host domain
    var regex = /^(?:https?:\/\/|\/\/)?(?:[^@\n]+@)?(?:www\.)?([^\n]+)/i;
    var host = regex.exec(url)[1];
    var socketProtocol = /^http:\/\//i.test(url) ? 'ws' : 'wss';
    return socketProtocol + "://" + host;
  };
  },{}],32:[function(require,module,exports){
  /**
   * Returns a timestamp in the format of `hours:minutes:seconds`
   */
  module.exports = function getTimeStamp() {
    var date = new Date();
    var hours = pad(date.getHours().toString());
    var minutes = pad(date.getMinutes().toString());
    var seconds = pad(date.getSeconds().toString());
    return hours + ':' + minutes + ':' + seconds;
  };
  /**
   * Adds zero to strings shorter than two characters
   */


  function pad(str) {
    return str.length !== 2 ? 0 + str : str;
  }
  },{}],33:[function(require,module,exports){
  module.exports = function has(object, key) {
    return Object.prototype.hasOwnProperty.call(object, key);
  };
  },{}],34:[function(require,module,exports){
  /**
   * Check if an object is a DOM element. Duck-typing based on `nodeType`.
   *
   * @param {*} obj
   */
  module.exports = function isDOMElement(obj) {
    return obj && typeof obj === 'object' && obj.nodeType === Node.ELEMENT_NODE;
  };
  },{}],35:[function(require,module,exports){
  function isNetworkError(xhr) {
    if (!xhr) {
      return false;
    }

    return xhr.readyState !== 0 && xhr.readyState !== 4 || xhr.status === 0;
  }

  module.exports = isNetworkError;
  },{}],36:[function(require,module,exports){
  /**
   * Check if a URL string is an object URL from `URL.createObjectURL`.
   *
   * @param {string} url
   * @returns {boolean}
   */
  module.exports = function isObjectURL(url) {
    return url.indexOf('blob:') === 0;
  };
  },{}],37:[function(require,module,exports){
  module.exports = function isPreviewSupported(fileType) {
    if (!fileType) return false;
    var fileTypeSpecific = fileType.split('/')[1]; // list of images that browsers can preview

    if (/^(jpe?g|gif|png|svg|svg\+xml|bmp|webp|avif)$/.test(fileTypeSpecific)) {
      return true;
    }

    return false;
  };
  },{}],38:[function(require,module,exports){
  // ___Why not add the mime-types package?
  //    It's 19.7kB gzipped, and we only need mime types for well-known extensions (for file previews).
  // ___Where to take new extensions from?
  //    https://github.com/jshttp/mime-db/blob/master/db.json
  module.exports = {
    md: 'text/markdown',
    markdown: 'text/markdown',
    mp4: 'video/mp4',
    mp3: 'audio/mp3',
    svg: 'image/svg+xml',
    jpg: 'image/jpeg',
    png: 'image/png',
    gif: 'image/gif',
    heic: 'image/heic',
    heif: 'image/heif',
    yaml: 'text/yaml',
    yml: 'text/yaml',
    csv: 'text/csv',
    tsv: 'text/tab-separated-values',
    tab: 'text/tab-separated-values',
    avi: 'video/x-msvideo',
    mks: 'video/x-matroska',
    mkv: 'video/x-matroska',
    mov: 'video/quicktime',
    doc: 'application/msword',
    docm: 'application/vnd.ms-word.document.macroenabled.12',
    docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    dot: 'application/msword',
    dotm: 'application/vnd.ms-word.template.macroenabled.12',
    dotx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
    xla: 'application/vnd.ms-excel',
    xlam: 'application/vnd.ms-excel.addin.macroenabled.12',
    xlc: 'application/vnd.ms-excel',
    xlf: 'application/x-xliff+xml',
    xlm: 'application/vnd.ms-excel',
    xls: 'application/vnd.ms-excel',
    xlsb: 'application/vnd.ms-excel.sheet.binary.macroenabled.12',
    xlsm: 'application/vnd.ms-excel.sheet.macroenabled.12',
    xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    xlt: 'application/vnd.ms-excel',
    xltm: 'application/vnd.ms-excel.template.macroenabled.12',
    xltx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
    xlw: 'application/vnd.ms-excel',
    txt: 'text/plain',
    text: 'text/plain',
    conf: 'text/plain',
    log: 'text/plain',
    pdf: 'application/pdf'
  };
  },{}],39:[function(require,module,exports){
  module.exports = function settle(promises) {
    var resolutions = [];
    var rejections = [];

    function resolved(value) {
      resolutions.push(value);
    }

    function rejected(error) {
      rejections.push(error);
    }

    var wait = Promise.all(promises.map(function (promise) {
      return promise.then(resolved, rejected);
    }));
    return wait.then(function () {
      return {
        successful: resolutions,
        failed: rejections
      };
    });
  };
  },{}],40:[function(require,module,exports){
  var _class, _temp;

  function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

  var _require = require('@uppy/core'),
      Plugin = _require.Plugin;

  var cuid = require('cuid');

  var Translator = require('@uppy/utils/lib/Translator');

  var _require2 = require('@uppy/companion-client'),
      Provider = _require2.Provider,
      RequestClient = _require2.RequestClient,
      Socket = _require2.Socket;

  var emitSocketProgress = require('@uppy/utils/lib/emitSocketProgress');

  var getSocketHost = require('@uppy/utils/lib/getSocketHost');

  var settle = require('@uppy/utils/lib/settle');

  var EventTracker = require('@uppy/utils/lib/EventTracker');

  var ProgressTimeout = require('@uppy/utils/lib/ProgressTimeout');

  var RateLimitedQueue = require('@uppy/utils/lib/RateLimitedQueue');

  var NetworkError = require('@uppy/utils/lib/NetworkError');

  var isNetworkError = require('@uppy/utils/lib/isNetworkError');

  function buildResponseError(xhr, error) {
    // No error message
    if (!error) error = new Error('Upload error'); // Got an error message string

    if (typeof error === 'string') error = new Error(error); // Got something else

    if (!(error instanceof Error)) {
      error = _extends(new Error('Upload error'), {
        data: error
      });
    }

    if (isNetworkError(xhr)) {
      error = new NetworkError(error, xhr);
      return error;
    }

    error.request = xhr;
    return error;
  }
  /**
   * Set `data.type` in the blob to `file.meta.type`,
   * because we might have detected a more accurate file type in Uppy
   * https://stackoverflow.com/a/50875615
   *
   * @param {object} file File object with `data`, `size` and `meta` properties
   * @returns {object} blob updated with the new `type` set from `file.meta.type`
   */


  function setTypeInBlob(file) {
    var dataWithUpdatedType = file.data.slice(0, file.data.size, file.meta.type);
    return dataWithUpdatedType;
  }

  module.exports = (_temp = _class = /*#__PURE__*/function (_Plugin) {
    _inheritsLoose(XHRUpload, _Plugin);

    function XHRUpload(uppy, opts) {
      var _this;

      _this = _Plugin.call(this, uppy, opts) || this;
      _this.type = 'uploader';
      _this.id = _this.opts.id || 'XHRUpload';
      _this.title = 'XHRUpload';
      _this.defaultLocale = {
        strings: {
          timedOut: 'Upload stalled for %{seconds} seconds, aborting.'
        }
      }; // Default options

      var defaultOptions = {
        formData: true,
        fieldName: 'files[]',
        method: 'post',
        metaFields: null,
        responseUrlFieldName: 'url',
        bundle: false,
        headers: {},
        timeout: 30 * 1000,
        limit: 0,
        withCredentials: false,
        responseType: '',

        /**
         * @typedef respObj
         * @property {string} responseText
         * @property {number} status
         * @property {string} statusText
         * @property {object.<string, string>} headers
         *
         * @param {string} responseText the response body string
         * @param {XMLHttpRequest | respObj} response the response object (XHR or similar)
         */
        getResponseData: function getResponseData(responseText, response) {
          var parsedResponse = {};

          try {
            parsedResponse = JSON.parse(responseText);
          } catch (err) {
            console.log(err);
          }

          return parsedResponse;
        },

        /**
         *
         * @param {string} responseText the response body string
         * @param {XMLHttpRequest | respObj} response the response object (XHR or similar)
         */
        getResponseError: function getResponseError(responseText, response) {
          var error = new Error('Upload error');

          if (isNetworkError(response)) {
            error = new NetworkError(error, response);
          }

          return error;
        },

        /**
         * Check if the response from the upload endpoint indicates that the upload was successful.
         *
         * @param {number} status the response status code
         * @param {string} responseText the response body string
         * @param {XMLHttpRequest | respObj} response the response object (XHR or similar)
         */
        validateStatus: function validateStatus(status, responseText, response) {
          return status >= 200 && status < 300;
        }
      };
      _this.opts = _extends({}, defaultOptions, opts);

      _this.i18nInit();

      _this.handleUpload = _this.handleUpload.bind(_assertThisInitialized(_this)); // Simultaneous upload limiting is shared across all uploads with this plugin.
      // __queue is for internal Uppy use only!

      if (_this.opts.__queue instanceof RateLimitedQueue) {
        _this.requests = _this.opts.__queue;
      } else {
        _this.requests = new RateLimitedQueue(_this.opts.limit);
      }

      if (_this.opts.bundle && !_this.opts.formData) {
        throw new Error('`opts.formData` must be true when `opts.bundle` is enabled.');
      }

      _this.uploaderEvents = Object.create(null);
      return _this;
    }

    var _proto = XHRUpload.prototype;

    _proto.setOptions = function setOptions(newOpts) {
      _Plugin.prototype.setOptions.call(this, newOpts);

      this.i18nInit();
    };

    _proto.i18nInit = function i18nInit() {
      this.translator = new Translator([this.defaultLocale, this.uppy.locale, this.opts.locale]);
      this.i18n = this.translator.translate.bind(this.translator);
      this.setPluginState(); // so that UI re-renders and we see the updated locale
    };

    _proto.getOptions = function getOptions(file) {
      var overrides = this.uppy.getState().xhrUpload;

      var opts = _extends({}, this.opts, overrides || {}, file.xhrUpload || {}, {
        headers: {}
      });

      _extends(opts.headers, this.opts.headers);

      if (overrides) {
        _extends(opts.headers, overrides.headers);
      }

      if (file.xhrUpload) {
        _extends(opts.headers, file.xhrUpload.headers);
      }

      return opts;
    };

    _proto.addMetadata = function addMetadata(formData, meta, opts) {
      var metaFields = Array.isArray(opts.metaFields) ? opts.metaFields // Send along all fields by default.
      : Object.keys(meta);
      metaFields.forEach(function (item) {
        formData.append(item, meta[item]);
      });
    };

    _proto.createFormDataUpload = function createFormDataUpload(file, opts) {
      var formPost = new FormData();
      this.addMetadata(formPost, file.meta, opts);
      var dataWithUpdatedType = setTypeInBlob(file);

      if (file.name) {
        formPost.append(opts.fieldName, dataWithUpdatedType, file.meta.name);
      } else {
        formPost.append(opts.fieldName, dataWithUpdatedType);
      }

      return formPost;
    };

    _proto.createBundledUpload = function createBundledUpload(files, opts) {
      var _this2 = this;

      var formPost = new FormData();

      var _this$uppy$getState = this.uppy.getState(),
          meta = _this$uppy$getState.meta;

      this.addMetadata(formPost, meta, opts);
      files.forEach(function (file) {
        var opts = _this2.getOptions(file);

        var dataWithUpdatedType = setTypeInBlob(file);

        if (file.name) {
          formPost.append(opts.fieldName, dataWithUpdatedType, file.name);
        } else {
          formPost.append(opts.fieldName, dataWithUpdatedType);
        }
      });
      return formPost;
    };

    _proto.createBareUpload = function createBareUpload(file, opts) {
      return file.data;
    };

    _proto.upload = function upload(file, current, total) {
      var _this3 = this;

      var opts = this.getOptions(file);
      this.uppy.log("uploading " + current + " of " + total);
      return new Promise(function (resolve, reject) {
        _this3.uppy.emit('upload-started', file);

        var data = opts.formData ? _this3.createFormDataUpload(file, opts) : _this3.createBareUpload(file, opts);
        var xhr = new XMLHttpRequest();
        _this3.uploaderEvents[file.id] = new EventTracker(_this3.uppy);
        var timer = new ProgressTimeout(opts.timeout, function () {
          xhr.abort();
          queuedRequest.done();
          var error = new Error(_this3.i18n('timedOut', {
            seconds: Math.ceil(opts.timeout / 1000)
          }));

          _this3.uppy.emit('upload-error', file, error);

          reject(error);
        });
        var id = cuid();
        xhr.upload.addEventListener('loadstart', function (ev) {
          _this3.uppy.log("[XHRUpload] " + id + " started");
        });
        xhr.upload.addEventListener('progress', function (ev) {
          _this3.uppy.log("[XHRUpload] " + id + " progress: " + ev.loaded + " / " + ev.total); // Begin checking for timeouts when progress starts, instead of loading,
          // to avoid timing out requests on browser concurrency queue


          timer.progress();

          if (ev.lengthComputable) {
            _this3.uppy.emit('upload-progress', file, {
              uploader: _this3,
              bytesUploaded: ev.loaded,
              bytesTotal: ev.total
            });
          }
        });
        xhr.addEventListener('load', function (ev) {
          _this3.uppy.log("[XHRUpload] " + id + " finished");

          timer.done();
          queuedRequest.done();

          if (_this3.uploaderEvents[file.id]) {
            _this3.uploaderEvents[file.id].remove();

            _this3.uploaderEvents[file.id] = null;
          }

          if (opts.validateStatus(ev.target.status, xhr.responseText, xhr)) {
            var body = opts.getResponseData(xhr.responseText, xhr);
            var uploadURL = body[opts.responseUrlFieldName];
            var uploadResp = {
              status: ev.target.status,
              body: body,
              uploadURL: uploadURL
            };

            _this3.uppy.emit('upload-success', file, uploadResp);

            if (uploadURL) {
              _this3.uppy.log("Download " + file.name + " from " + uploadURL);
            }

            return resolve(file);
          } else {
            var _body = opts.getResponseData(xhr.responseText, xhr);

            var error = buildResponseError(xhr, opts.getResponseError(xhr.responseText, xhr));
            var response = {
              status: ev.target.status,
              body: _body
            };

            _this3.uppy.emit('upload-error', file, error, response);

            return reject(error);
          }
        });
        xhr.addEventListener('error', function (ev) {
          _this3.uppy.log("[XHRUpload] " + id + " errored");

          timer.done();
          queuedRequest.done();

          if (_this3.uploaderEvents[file.id]) {
            _this3.uploaderEvents[file.id].remove();

            _this3.uploaderEvents[file.id] = null;
          }

          var error = buildResponseError(xhr, opts.getResponseError(xhr.responseText, xhr));

          _this3.uppy.emit('upload-error', file, error);

          return reject(error);
        });
        xhr.open(opts.method.toUpperCase(), opts.endpoint, true); // IE10 does not allow setting `withCredentials` and `responseType`
        // before `open()` is called.

        xhr.withCredentials = opts.withCredentials;

        if (opts.responseType !== '') {
          xhr.responseType = opts.responseType;
        }

        Object.keys(opts.headers).forEach(function (header) {
          xhr.setRequestHeader(header, opts.headers[header]);
        });

        var queuedRequest = _this3.requests.run(function () {
          xhr.send(data);
          return function () {
            timer.done();
            xhr.abort();
          };
        });

        _this3.onFileRemove(file.id, function () {
          queuedRequest.abort();
          reject(new Error('File removed'));
        });

        _this3.onCancelAll(file.id, function () {
          queuedRequest.abort();
          reject(new Error('Upload cancelled'));
        });
      });
    };

    _proto.uploadRemote = function uploadRemote(file, current, total) {
      var _this4 = this;

      var opts = this.getOptions(file);
      return new Promise(function (resolve, reject) {
        _this4.uppy.emit('upload-started', file);

        var fields = {};
        var metaFields = Array.isArray(opts.metaFields) ? opts.metaFields // Send along all fields by default.
        : Object.keys(file.meta);
        metaFields.forEach(function (name) {
          fields[name] = file.meta[name];
        });
        var Client = file.remote.providerOptions.provider ? Provider : RequestClient;
        var client = new Client(_this4.uppy, file.remote.providerOptions);
        client.post(file.remote.url, _extends({}, file.remote.body, {
          endpoint: opts.endpoint,
          size: file.data.size,
          fieldname: opts.fieldName,
          metadata: fields,
          httpMethod: opts.method,
          useFormData: opts.formData,
          headers: opts.headers
        })).then(function (res) {
          var token = res.token;
          var host = getSocketHost(file.remote.companionUrl);
          var socket = new Socket({
            target: host + "/api/" + token,
            autoOpen: false
          });
          _this4.uploaderEvents[file.id] = new EventTracker(_this4.uppy);

          _this4.onFileRemove(file.id, function () {
            socket.send('pause', {});
            queuedRequest.abort();
            resolve("upload " + file.id + " was removed");
          });

          _this4.onCancelAll(file.id, function () {
            socket.send('pause', {});
            queuedRequest.abort();
            resolve("upload " + file.id + " was canceled");
          });

          _this4.onRetry(file.id, function () {
            socket.send('pause', {});
            socket.send('resume', {});
          });

          _this4.onRetryAll(file.id, function () {
            socket.send('pause', {});
            socket.send('resume', {});
          });

          socket.on('progress', function (progressData) {
            return emitSocketProgress(_this4, progressData, file);
          });
          socket.on('success', function (data) {
            var body = opts.getResponseData(data.response.responseText, data.response);
            var uploadURL = body[opts.responseUrlFieldName];
            var uploadResp = {
              status: data.response.status,
              body: body,
              uploadURL: uploadURL
            };

            _this4.uppy.emit('upload-success', file, uploadResp);

            queuedRequest.done();

            if (_this4.uploaderEvents[file.id]) {
              _this4.uploaderEvents[file.id].remove();

              _this4.uploaderEvents[file.id] = null;
            }

            return resolve();
          });
          socket.on('error', function (errData) {
            var resp = errData.response;
            var error = resp ? opts.getResponseError(resp.responseText, resp) : _extends(new Error(errData.error.message), {
              cause: errData.error
            });

            _this4.uppy.emit('upload-error', file, error);

            queuedRequest.done();

            if (_this4.uploaderEvents[file.id]) {
              _this4.uploaderEvents[file.id].remove();

              _this4.uploaderEvents[file.id] = null;
            }

            reject(error);
          });

          var queuedRequest = _this4.requests.run(function () {
            socket.open();

            if (file.isPaused) {
              socket.send('pause', {});
            }

            return function () {
              return socket.close();
            };
          });
        }).catch(function (err) {
          _this4.uppy.emit('upload-error', file, err);

          reject(err);
        });
      });
    };

    _proto.uploadBundle = function uploadBundle(files) {
      var _this5 = this;

      return new Promise(function (resolve, reject) {
        var endpoint = _this5.opts.endpoint;
        var method = _this5.opts.method;

        var optsFromState = _this5.uppy.getState().xhrUpload;

        var formData = _this5.createBundledUpload(files, _extends({}, _this5.opts, optsFromState || {}));

        var xhr = new XMLHttpRequest();
        var timer = new ProgressTimeout(_this5.opts.timeout, function () {
          xhr.abort();
          var error = new Error(_this5.i18n('timedOut', {
            seconds: Math.ceil(_this5.opts.timeout / 1000)
          }));
          emitError(error);
          reject(error);
        });

        var emitError = function emitError(error) {
          files.forEach(function (file) {
            _this5.uppy.emit('upload-error', file, error);
          });
        };

        xhr.upload.addEventListener('loadstart', function (ev) {
          _this5.uppy.log('[XHRUpload] started uploading bundle');

          timer.progress();
        });
        xhr.upload.addEventListener('progress', function (ev) {
          timer.progress();
          if (!ev.lengthComputable) return;
          files.forEach(function (file) {
            _this5.uppy.emit('upload-progress', file, {
              uploader: _this5,
              bytesUploaded: ev.loaded / ev.total * file.size,
              bytesTotal: file.size
            });
          });
        });
        xhr.addEventListener('load', function (ev) {
          timer.done();

          if (_this5.opts.validateStatus(ev.target.status, xhr.responseText, xhr)) {
            var body = _this5.opts.getResponseData(xhr.responseText, xhr);

            var uploadResp = {
              status: ev.target.status,
              body: body
            };
            files.forEach(function (file) {
              _this5.uppy.emit('upload-success', file, uploadResp);
            });
            return resolve();
          }

          var error = _this5.opts.getResponseError(xhr.responseText, xhr) || new Error('Upload error');
          error.request = xhr;
          emitError(error);
          return reject(error);
        });
        xhr.addEventListener('error', function (ev) {
          timer.done();
          var error = _this5.opts.getResponseError(xhr.responseText, xhr) || new Error('Upload error');
          emitError(error);
          return reject(error);
        });

        _this5.uppy.on('cancel-all', function () {
          timer.done();
          xhr.abort();
        });

        xhr.open(method.toUpperCase(), endpoint, true); // IE10 does not allow setting `withCredentials` and `responseType`
        // before `open()` is called.

        xhr.withCredentials = _this5.opts.withCredentials;

        if (_this5.opts.responseType !== '') {
          xhr.responseType = _this5.opts.responseType;
        }

        Object.keys(_this5.opts.headers).forEach(function (header) {
          xhr.setRequestHeader(header, _this5.opts.headers[header]);
        });
        xhr.send(formData);
        files.forEach(function (file) {
          _this5.uppy.emit('upload-started', file);
        });
      });
    };

    _proto.uploadFiles = function uploadFiles(files) {
      var _this6 = this;

      var promises = files.map(function (file, i) {
        var current = parseInt(i, 10) + 1;
        var total = files.length;

        if (file.error) {
          return Promise.reject(new Error(file.error));
        } else if (file.isRemote) {
          return _this6.uploadRemote(file, current, total);
        } else {
          return _this6.upload(file, current, total);
        }
      });
      return settle(promises);
    };

    _proto.onFileRemove = function onFileRemove(fileID, cb) {
      this.uploaderEvents[fileID].on('file-removed', function (file) {
        if (fileID === file.id) cb(file.id);
      });
    };

    _proto.onRetry = function onRetry(fileID, cb) {
      this.uploaderEvents[fileID].on('upload-retry', function (targetFileID) {
        if (fileID === targetFileID) {
          cb();
        }
      });
    };

    _proto.onRetryAll = function onRetryAll(fileID, cb) {
      var _this7 = this;

      this.uploaderEvents[fileID].on('retry-all', function (filesToRetry) {
        if (!_this7.uppy.getFile(fileID)) return;
        cb();
      });
    };

    _proto.onCancelAll = function onCancelAll(fileID, cb) {
      var _this8 = this;

      this.uploaderEvents[fileID].on('cancel-all', function () {
        if (!_this8.uppy.getFile(fileID)) return;
        cb();
      });
    };

    _proto.handleUpload = function handleUpload(fileIDs) {
      var _this9 = this;

      if (fileIDs.length === 0) {
        this.uppy.log('[XHRUpload] No files to upload!');
        return Promise.resolve();
      } // no limit configured by the user, and no RateLimitedQueue passed in by a "parent" plugin (basically just AwsS3) using the top secret `__queue` option


      if (this.opts.limit === 0 && !this.opts.__queue) {
        this.uppy.log('[XHRUpload] When uploading multiple files at once, consider setting the `limit` option (to `10` for example), to limit the number of concurrent uploads, which helps prevent memory and network issues: https://uppy.io/docs/xhr-upload/#limit-0', 'warning');
      }

      this.uppy.log('[XHRUpload] Uploading...');
      var files = fileIDs.map(function (fileID) {
        return _this9.uppy.getFile(fileID);
      });

      if (this.opts.bundle) {
        // if bundle: true, we don’t support remote uploads
        var isSomeFileRemote = files.some(function (file) {
          return file.isRemote;
        });

        if (isSomeFileRemote) {
          throw new Error('Can’t upload remote files when bundle: true option is set');
        }

        return this.uploadBundle(files);
      }

      return this.uploadFiles(files).then(function () {
        return null;
      });
    };

    _proto.install = function install() {
      if (this.opts.bundle) {
        var _this$uppy$getState2 = this.uppy.getState(),
            capabilities = _this$uppy$getState2.capabilities;

        this.uppy.setState({
          capabilities: _extends({}, capabilities, {
            individualCancellation: false
          })
        });
      }

      this.uppy.addUploader(this.handleUpload);
    };

    _proto.uninstall = function uninstall() {
      if (this.opts.bundle) {
        var _this$uppy$getState3 = this.uppy.getState(),
            capabilities = _this$uppy$getState3.capabilities;

        this.uppy.setState({
          capabilities: _extends({}, capabilities, {
            individualCancellation: true
          })
        });
      }

      this.uppy.removeUploader(this.handleUpload);
    };

    return XHRUpload;
  }(Plugin), _class.VERSION = "1.6.7", _temp);
  },{"@uppy/companion-client":11,"@uppy/core":14,"@uppy/utils/lib/EventTracker":19,"@uppy/utils/lib/NetworkError":20,"@uppy/utils/lib/ProgressTimeout":21,"@uppy/utils/lib/RateLimitedQueue":22,"@uppy/utils/lib/Translator":23,"@uppy/utils/lib/emitSocketProgress":25,"@uppy/utils/lib/getSocketHost":31,"@uppy/utils/lib/isNetworkError":35,"@uppy/utils/lib/settle":39,"cuid":41}],41:[function(require,module,exports){
  /**
   * cuid.js
   * Collision-resistant UID generator for browsers and node.
   * Sequential for fast db lookups and recency sorting.
   * Safe for element IDs and server-side lookups.
   *
   * Extracted from CLCTR
   *
   * Copyright (c) Eric Elliott 2012
   * MIT License
   */

  var fingerprint = require('./lib/fingerprint.js');
  var pad = require('./lib/pad.js');
  var getRandomValue = require('./lib/getRandomValue.js');

  var c = 0,
    blockSize = 4,
    base = 36,
    discreteValues = Math.pow(base, blockSize);

  function randomBlock () {
    return pad((getRandomValue() *
      discreteValues << 0)
      .toString(base), blockSize);
  }

  function safeCounter () {
    c = c < discreteValues ? c : 0;
    c++; // this is not subliminal
    return c - 1;
  }

  function cuid () {
    // Starting with a lowercase letter makes
    // it HTML element ID friendly.
    var letter = 'c', // hard-coded allows for sequential access

      // timestamp
      // warning: this exposes the exact date and time
      // that the uid was created.
      timestamp = (new Date().getTime()).toString(base),

      // Prevent same-machine collisions.
      counter = pad(safeCounter().toString(base), blockSize),

      // A few chars to generate distinct ids for different
      // clients (so different computers are far less
      // likely to generate the same id)
      print = fingerprint(),

      // Grab some more chars from Math.random()
      random = randomBlock() + randomBlock();

    return letter + timestamp + counter + print + random;
  }

  cuid.slug = function slug () {
    var date = new Date().getTime().toString(36),
      counter = safeCounter().toString(36).slice(-4),
      print = fingerprint().slice(0, 1) +
        fingerprint().slice(-1),
      random = randomBlock().slice(-2);

    return date.slice(-2) +
      counter + print + random;
  };

  cuid.isCuid = function isCuid (stringToCheck) {
    if (typeof stringToCheck !== 'string') return false;
    if (stringToCheck.startsWith('c')) return true;
    return false;
  };

  cuid.isSlug = function isSlug (stringToCheck) {
    if (typeof stringToCheck !== 'string') return false;
    var stringLength = stringToCheck.length;
    if (stringLength >= 7 && stringLength <= 10) return true;
    return false;
  };

  cuid.fingerprint = fingerprint;

  module.exports = cuid;

  },{"./lib/fingerprint.js":42,"./lib/getRandomValue.js":43,"./lib/pad.js":44}],42:[function(require,module,exports){
  var pad = require('./pad.js');

  var env = typeof window === 'object' ? window : self;
  var globalCount = Object.keys(env).length;
  var mimeTypesLength = navigator.mimeTypes ? navigator.mimeTypes.length : 0;
  var clientId = pad((mimeTypesLength +
    navigator.userAgent.length).toString(36) +
    globalCount.toString(36), 4);

  module.exports = function fingerprint () {
    return clientId;
  };

  },{"./pad.js":44}],43:[function(require,module,exports){

  var getRandomValue;

  var crypto = typeof window !== 'undefined' &&
    (window.crypto || window.msCrypto) ||
    typeof self !== 'undefined' &&
    self.crypto;

  if (crypto) {
      var lim = Math.pow(2, 32) - 1;
      getRandomValue = function () {
          return Math.abs(crypto.getRandomValues(new Uint32Array(1))[0] / lim);
      };
  } else {
      getRandomValue = Math.random;
  }

  module.exports = getRandomValue;

  },{}],44:[function(require,module,exports){
  module.exports = function pad (num, size) {
    var s = '000000000' + num;
    return s.substr(s.length - size);
  };

  },{}],45:[function(require,module,exports){
  (function (process,global,Buffer){(function (){
  !function(e,t){"object"==typeof exports&&"undefined"!=typeof module?t(exports):"function"==typeof define&&define.amd?define("exifr",["exports"],t):t((e=e||self).exifr={})}(this,(function(e){"use strict";function t(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function n(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}function r(e,t,r){return t&&n(e.prototype,t),r&&n(e,r),e}function i(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function a(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function");e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,writable:!0,configurable:!0}});var n=["prototype","__proto__","caller","arguments","length","name"];Object.getOwnPropertyNames(t).forEach((function(r){-1===n.indexOf(r)&&e[r]!==t[r]&&(e[r]=t[r])})),t&&u(e,t)}function s(e){return(s=Object.setPrototypeOf?Object.getPrototypeOf:function(e){return e.__proto__||Object.getPrototypeOf(e)})(e)}function u(e,t){return(u=Object.setPrototypeOf||function(e,t){return e.__proto__=t,e})(e,t)}function o(){if("undefined"==typeof Reflect||!Reflect.construct)return!1;if(Reflect.construct.sham)return!1;if("function"==typeof Proxy)return!0;try{return Date.prototype.toString.call(Reflect.construct(Date,[],(function(){}))),!0}catch(e){return!1}}function f(e,t,n){return(f=o()?Reflect.construct:function(e,t,n){var r=[null];r.push.apply(r,t);var i=new(Function.bind.apply(e,r));return n&&u(i,n.prototype),i}).apply(null,arguments)}function c(e){var t="function"==typeof Map?new Map:void 0;return(c=function(e){if(null===e||(n=e,-1===Function.toString.call(n).indexOf("[native code]")))return e;var n;if("function"!=typeof e)throw new TypeError("Super expression must either be null or a function");if(void 0!==t){if(t.has(e))return t.get(e);t.set(e,r)}function r(){return f(e,arguments,s(this).constructor)}return r.prototype=Object.create(e.prototype,{constructor:{value:r,enumerable:!1,writable:!0,configurable:!0}}),u(r,e)})(e)}function h(e){if(void 0===e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return e}function l(e,t){return!t||"object"!=typeof t&&"function"!=typeof t?h(e):t}function d(e,t,n){return(d="undefined"!=typeof Reflect&&Reflect.get?Reflect.get:function(e,t,n){var r=function(e,t){for(;!Object.prototype.hasOwnProperty.call(e,t)&&null!==(e=s(e)););return e}(e,t);if(r){var i=Object.getOwnPropertyDescriptor(r,t);return i.get?i.get.call(n):i.value}})(e,t,n||e)}var v=Object.values||function(e){var t=[];for(var n in e)t.push(e[n]);return t},p=Object.entries||function(e){var t=[];for(var n in e)t.push([n,e[n]]);return t},y=Object.assign||function(e){for(var t=arguments.length,n=new Array(t>1?t-1:0),r=1;r<t;r++)n[r-1]=arguments[r];return n.forEach((function(t){for(var n in t)e[n]=t[n]})),e},g=Object.fromEntries||function(e){var t={};return k(e).forEach((function(e){var n=e[0],r=e[1];t[n]=r})),t},k=Array.from||function(e){if(e instanceof S){var t=[];return e.forEach((function(e,n){return t.push([n,e])})),t}return Array.prototype.slice.call(e)};function m(e){return-1!==this.indexOf(e)}Array.prototype.includes||(Array.prototype.includes=m),String.prototype.includes||(String.prototype.includes=m),String.prototype.startsWith||(String.prototype.startsWith=function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;return this.substring(t,t+e.length)===e}),String.prototype.endsWith||(String.prototype.endsWith=function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.length;return this.substring(t-e.length,t)===e});var b="undefined"!=typeof self?self:global,A=b.fetch||function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{};return new Promise((function(n,r){var i=new XMLHttpRequest;if(i.open("get",e,!0),i.responseType="arraybuffer",i.onerror=r,t.headers)for(var a in t.headers)i.setRequestHeader(a,t.headers[a]);i.onload=function(){n({ok:i.status>=200&&i.status<300,status:i.status,arrayBuffer:function(){return Promise.resolve(i.response)}})},i.send(null)}))},w=function(e){var t=[];if(Object.defineProperties(t,{size:{get:function(){return this.length}},has:{value:function(e){return-1!==this.indexOf(e)}},add:{value:function(e){this.has(e)||this.push(e)}},delete:{value:function(e){if(this.has(e)){var t=this.indexOf(e);this.splice(t,1)}}}}),Array.isArray(e))for(var n=0;n<e.length;n++)t.add(e[n]);return t},O=function(e){return new S(e)},S=void 0!==b.Map&&void 0!==b.Map.prototype.keys?b.Map:function(){function e(n){if(t(this,e),this.clear(),n)for(var r=0;r<n.length;r++)this.set(n[r][0],n[r][1])}return r(e,[{key:"clear",value:function(){this._map={},this._keys=[]}},{key:"get",value:function(e){return this._map["map_"+e]}},{key:"set",value:function(e,t){return this._map["map_"+e]=t,this._keys.indexOf(e)<0&&this._keys.push(e),this}},{key:"has",value:function(e){return this._keys.indexOf(e)>=0}},{key:"delete",value:function(e){var t=this._keys.indexOf(e);return!(t<0)&&(delete this._map["map_"+e],this._keys.splice(t,1),!0)}},{key:"keys",value:function(){return this._keys.slice(0)}},{key:"values",value:function(){var e=this;return this._keys.map((function(t){return e.get(t)}))}},{key:"entries",value:function(){var e=this;return this._keys.map((function(t){return[t,e.get(t)]}))}},{key:"forEach",value:function(e,t){for(var n=0;n<this._keys.length;n++)e.call(t,this._map["map_"+this._keys[n]],this._keys[n],this)}},{key:"size",get:function(){return this._keys.length}}]),e}(),P="undefined"!=typeof self?self:global,U="undefined"!=typeof navigator,x=U&&"undefined"==typeof HTMLImageElement,C=!("undefined"==typeof global||"undefined"==typeof process||!process.versions||!process.versions.node),_=P.Buffer,j=!!_;var B=function(e){return void 0!==e};function V(e){return void 0===e||(e instanceof S?0===e.size:0===v(e).filter(B).length)}function I(e){var t=new Error(e);throw delete t.stack,t}function z(e){var t=function(e){var t=0;return e.ifd0.enabled&&(t+=1024),e.exif.enabled&&(t+=2048),e.makerNote&&(t+=2048),e.userComment&&(t+=1024),e.gps.enabled&&(t+=512),e.interop.enabled&&(t+=100),e.ifd1.enabled&&(t+=1024),t+2048}(e);return e.jfif.enabled&&(t+=50),e.xmp.enabled&&(t+=2e4),e.iptc.enabled&&(t+=14e3),e.icc.enabled&&(t+=6e3),t}var L="undefined"!=typeof TextDecoder?new TextDecoder("utf-8"):void 0;function T(e){return L?L.decode(e):j?Buffer.from(e).toString("utf8"):decodeURIComponent(escape(String.fromCharCode.apply(null,e)))}var F=function(){function e(n){var r=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0,i=arguments.length>2?arguments[2]:void 0,a=arguments.length>3?arguments[3]:void 0;if(t(this,e),"boolean"==typeof a&&(this.le=a),Array.isArray(n)&&(n=new Uint8Array(n)),0===n)this.byteOffset=0,this.byteLength=0;else if(n instanceof ArrayBuffer){void 0===i&&(i=n.byteLength-r);var s=new DataView(n,r,i);this._swapDataView(s)}else if(n instanceof Uint8Array||n instanceof DataView||n instanceof e){void 0===i&&(i=n.byteLength-r),(r+=n.byteOffset)+i>n.byteOffset+n.byteLength&&I("Creating view outside of available memory in ArrayBuffer");var u=new DataView(n.buffer,r,i);this._swapDataView(u)}else if("number"==typeof n){var o=new DataView(new ArrayBuffer(n));this._swapDataView(o)}else I("Invalid input argument for BufferView: "+n)}return r(e,null,[{key:"from",value:function(t,n){return t instanceof this&&t.le===n?t:new e(t,void 0,void 0,n)}}]),r(e,[{key:"_swapArrayBuffer",value:function(e){this._swapDataView(new DataView(e))}},{key:"_swapBuffer",value:function(e){this._swapDataView(new DataView(e.buffer,e.byteOffset,e.byteLength))}},{key:"_swapDataView",value:function(e){this.dataView=e,this.buffer=e.buffer,this.byteOffset=e.byteOffset,this.byteLength=e.byteLength}},{key:"_lengthToEnd",value:function(e){return this.byteLength-e}},{key:"set",value:function(t,n){var r=arguments.length>2&&void 0!==arguments[2]?arguments[2]:e;t instanceof DataView||t instanceof e?t=new Uint8Array(t.buffer,t.byteOffset,t.byteLength):t instanceof ArrayBuffer&&(t=new Uint8Array(t)),t instanceof Uint8Array||I("BufferView.set(): Invalid data argument.");var i=this.toUint8();return i.set(t,n),new r(this,n,t.byteLength)}},{key:"subarray",value:function(t,n){return new e(this,t,n=n||this._lengthToEnd(t))}},{key:"toUint8",value:function(){return new Uint8Array(this.buffer,this.byteOffset,this.byteLength)}},{key:"getUint8Array",value:function(e,t){return new Uint8Array(this.buffer,this.byteOffset+e,t)}},{key:"getString",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:0,t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.byteLength,n=this.getUint8Array(e,t);return T(n)}},{key:"getUnicodeString",value:function(){for(var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:0,t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.byteLength,n=[],r=0;r<t&&e+r<this.byteLength;r+=2)n.push(this.getUint16(e+r));return n.map((function(e){return String.fromCharCode(e)})).join("")}},{key:"getInt8",value:function(e){return this.dataView.getInt8(e)}},{key:"getUint8",value:function(e){return this.dataView.getUint8(e)}},{key:"getInt16",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.le;return this.dataView.getInt16(e,t)}},{key:"getInt32",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.le;return this.dataView.getInt32(e,t)}},{key:"getUint16",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.le;return this.dataView.getUint16(e,t)}},{key:"getUint32",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.le;return this.dataView.getUint32(e,t)}},{key:"getFloat32",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.le;return this.dataView.getFloat32(e,t)}},{key:"getFloat64",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.le;return this.dataView.getFloat64(e,t)}},{key:"getFloat",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.le;return this.dataView.getFloat32(e,t)}},{key:"getDouble",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:this.le;return this.dataView.getFloat64(e,t)}},{key:"getUintBytes",value:function(e,t,n){switch(t){case 1:return this.getUint8(e,n);case 2:return this.getUint16(e,n);case 4:return this.getUint32(e,n);case 8:return this.getUint64&&this.getUint64(e,n)}}},{key:"getUint",value:function(e,t,n){switch(t){case 8:return this.getUint8(e,n);case 16:return this.getUint16(e,n);case 32:return this.getUint32(e,n);case 64:return this.getUint64&&this.getUint64(e,n)}}},{key:"toString",value:function(e){return this.dataView.toString(e,this.constructor.name)}},{key:"ensureChunk",value:function(){}}]),e}();function E(e,t){I("".concat(e," '").concat(t,"' was not loaded, try using full build of exifr."))}var D=function(e){function n(e){var r;return t(this,n),(r=l(this,s(n).call(this))).kind=e,r}return a(n,e),r(n,[{key:"get",value:function(e,t){return this.has(e)||E(this.kind,e),t&&(e in t||function(e,t){I("Unknown ".concat(e," '").concat(t,"'."))}(this.kind,e),t[e].enabled||E(this.kind,e)),d(s(n.prototype),"get",this).call(this,e)}},{key:"keyList",value:function(){return k(this.keys())}}]),n}(c(S)),M=new D("file parser"),N=new D("segment parser"),R=new D("file reader");function W(e){return function(){for(var t=[],n=0;n<arguments.length;n++)t[n]=arguments[n];try{return Promise.resolve(e.apply(this,t))}catch(e){return Promise.reject(e)}}}function K(e,t,n){return n?t?t(e):e:(e&&e.then||(e=Promise.resolve(e)),t?e.then(t):e)}var H=W((function(e){return new Promise((function(t,n){var r=new FileReader;r.onloadend=function(){return t(r.result||new ArrayBuffer)},r.onerror=n,r.readAsArrayBuffer(e)}))})),X=W((function(e){return A(e).then((function(e){return e.arrayBuffer()}))})),Y=W((function(e,t){return K(t(e),(function(e){return new F(e)}))})),G=W((function(e,t,n){var r=new(R.get(n))(e,t);return K(r.read(),(function(){return r}))})),J=W((function(e,t,n,r){return R.has(n)?G(e,t,n):r?Y(e,r):(I("Parser ".concat(n," is not loaded")),K())}));function q(e,t){return(n=e).startsWith("data:")||n.length>1e4?G(e,t,"base64"):U?J(e,t,"url",X):C?G(e,t,"fs"):void I("Invalid input argument");var n}var Q=function(e){function n(){return t(this,n),l(this,s(n).apply(this,arguments))}return a(n,e),r(n,[{key:"tagKeys",get:function(){return this.allKeys||(this.allKeys=k(this.keys())),this.allKeys}},{key:"tagValues",get:function(){return this.allValues||(this.allValues=k(this.values())),this.allValues}}]),n}(c(S));function Z(e,t,n){var r=new Q,i=n;Array.isArray(i)||("function"==typeof i.entries&&(i=i.entries()),i=k(i));for(var a=0;a<i.length;a++){var s=i[a],u=s[0],o=s[1];r.set(u,o)}if(Array.isArray(t)){var f=t;Array.isArray(f)||("function"==typeof f.entries&&(f=f.entries()),f=k(f));for(var c=0;c<f.length;c++){var h=f[c];e.set(h,r)}}else e.set(t,r);return r}function $(e,t,n){var r,i=e.get(t),a=n;Array.isArray(a)||("function"==typeof a.entries&&(a=a.entries()),a=k(a));for(var s=0;s<a.length;s++)r=a[s],i.set(r[0],r[1])}var ee=O(),te=O(),ne=O(),re=["chunked","firstChunkSize","firstChunkSizeNode","firstChunkSizeBrowser","chunkSize","chunkLimit"],ie=["jfif","xmp","icc","iptc"],ae=["tiff"].concat(ie),se=["ifd0","ifd1","exif","gps","interop"],ue=[].concat(ae,se),oe=["makerNote","userComment"],fe=["translateKeys","translateValues","reviveValues","multiSegment"],ce=[].concat(fe,["sanitize","mergeOutput"]),he=function(){function e(){t(this,e)}return r(e,[{key:"translate",get:function(){return this.translateKeys||this.translateValues||this.reviveValues}}]),e}(),le=function(e){function n(e,r,a,u){var o;if(t(this,n),i(h(o=l(this,s(n).call(this))),"enabled",!1),i(h(o),"skip",w()),i(h(o),"pick",w()),i(h(o),"deps",w()),i(h(o),"translateKeys",!1),i(h(o),"translateValues",!1),i(h(o),"reviveValues",!1),o.key=e,o.enabled=r,o.parse=o.enabled,o.applyInheritables(u),o.canBeFiltered=se.includes(e),o.canBeFiltered&&(o.dict=ee.get(e)),void 0!==a)if(Array.isArray(a))o.parse=o.enabled=!0,o.canBeFiltered&&a.length>0&&o.translateTagSet(a,o.pick);else if("object"==typeof a){if(o.enabled=!0,o.parse=!1!==a.parse,o.canBeFiltered){var f=a.pick,c=a.skip;f&&f.length>0&&o.translateTagSet(f,o.pick),c&&c.length>0&&o.translateTagSet(c,o.skip)}o.applyInheritables(a)}else!0===a||!1===a?o.parse=o.enabled=a:I("Invalid options argument: ".concat(a));return o}return a(n,e),r(n,[{key:"needed",get:function(){return this.enabled||this.deps.size>0}}]),r(n,[{key:"applyInheritables",value:function(e){var t,n,r=fe;Array.isArray(r)||("function"==typeof r.entries&&(r=r.entries()),r=k(r));for(var i=0;i<r.length;i++)void 0!==(n=e[t=r[i]])&&(this[t]=n)}},{key:"translateTagSet",value:function(e,t){if(this.dict){var n,r,i=this.dict,a=i.tagKeys,s=i.tagValues,u=e;Array.isArray(u)||("function"==typeof u.entries&&(u=u.entries()),u=k(u));for(var o=0;o<u.length;o++)"string"==typeof(n=u[o])?(-1===(r=s.indexOf(n))&&(r=a.indexOf(Number(n))),-1!==r&&t.add(Number(a[r]))):t.add(n)}else{var f=e;Array.isArray(f)||("function"==typeof f.entries&&(f=f.entries()),f=k(f));for(var c=0;c<f.length;c++){var h=f[c];t.add(h)}}}},{key:"finalizeFilters",value:function(){!this.enabled&&this.deps.size>0?(this.enabled=!0,ke(this.pick,this.deps)):this.enabled&&this.pick.size>0&&ke(this.pick,this.deps)}}]),n}(he),de={jfif:!1,tiff:!0,xmp:!1,icc:!1,iptc:!1,ifd0:!0,ifd1:!1,exif:!0,gps:!0,interop:!1,makerNote:!1,userComment:!1,multiSegment:!1,skip:[],pick:[],translateKeys:!0,translateValues:!0,reviveValues:!0,sanitize:!0,mergeOutput:!0,silentErrors:!0,chunked:!0,firstChunkSize:void 0,firstChunkSizeNode:512,firstChunkSizeBrowser:65536,chunkSize:65536,chunkLimit:5},ve=O(),pe=function(e){function n(e){var r;return t(this,n),r=l(this,s(n).call(this)),!0===e?r.setupFromTrue():void 0===e?r.setupFromUndefined():Array.isArray(e)?r.setupFromArray(e):"object"==typeof e?r.setupFromObject(e):I("Invalid options argument ".concat(e)),void 0===r.firstChunkSize&&(r.firstChunkSize=U?r.firstChunkSizeBrowser:r.firstChunkSizeNode),r.mergeOutput&&(r.ifd1.enabled=!1),r.filterNestedSegmentTags(),r.traverseTiffDependencyTree(),r.checkLoadedPlugins(),r}return a(n,e),r(n,null,[{key:"useCached",value:function(e){var t=ve.get(e);return void 0!==t?t:(t=new this(e),ve.set(e,t),t)}}]),r(n,[{key:"setupFromUndefined",value:function(){var e,t=re;Array.isArray(t)||("function"==typeof t.entries&&(t=t.entries()),t=k(t));for(var n=0;n<t.length;n++)this[e=t[n]]=de[e];var r=ce;Array.isArray(r)||("function"==typeof r.entries&&(r=r.entries()),r=k(r));for(var i=0;i<r.length;i++)this[e=r[i]]=de[e];var a=oe;Array.isArray(a)||("function"==typeof a.entries&&(a=a.entries()),a=k(a));for(var s=0;s<a.length;s++)this[e=a[s]]=de[e];var u=ue;Array.isArray(u)||("function"==typeof u.entries&&(u=u.entries()),u=k(u));for(var o=0;o<u.length;o++)this[e=u[o]]=new le(e,de[e],void 0,this)}},{key:"setupFromTrue",value:function(){var e,t=re;Array.isArray(t)||("function"==typeof t.entries&&(t=t.entries()),t=k(t));for(var n=0;n<t.length;n++)this[e=t[n]]=de[e];var r=ce;Array.isArray(r)||("function"==typeof r.entries&&(r=r.entries()),r=k(r));for(var i=0;i<r.length;i++)this[e=r[i]]=de[e];var a=oe;Array.isArray(a)||("function"==typeof a.entries&&(a=a.entries()),a=k(a));for(var s=0;s<a.length;s++)this[e=a[s]]=!0;var u=ue;Array.isArray(u)||("function"==typeof u.entries&&(u=u.entries()),u=k(u));for(var o=0;o<u.length;o++)this[e=u[o]]=new le(e,!0,void 0,this)}},{key:"setupFromArray",value:function(e){var t,n=re;Array.isArray(n)||("function"==typeof n.entries&&(n=n.entries()),n=k(n));for(var r=0;r<n.length;r++)this[t=n[r]]=de[t];var i=ce;Array.isArray(i)||("function"==typeof i.entries&&(i=i.entries()),i=k(i));for(var a=0;a<i.length;a++)this[t=i[a]]=de[t];var s=oe;Array.isArray(s)||("function"==typeof s.entries&&(s=s.entries()),s=k(s));for(var u=0;u<s.length;u++)this[t=s[u]]=de[t];var o=ue;Array.isArray(o)||("function"==typeof o.entries&&(o=o.entries()),o=k(o));for(var f=0;f<o.length;f++)this[t=o[f]]=new le(t,!1,void 0,this);this.setupGlobalFilters(e,void 0,se)}},{key:"setupFromObject",value:function(e){var t;se.ifd0=se.ifd0||se.image,se.ifd1=se.ifd1||se.thumbnail,y(this,e);var n=re;Array.isArray(n)||("function"==typeof n.entries&&(n=n.entries()),n=k(n));for(var r=0;r<n.length;r++)this[t=n[r]]=ge(e[t],de[t]);var i=ce;Array.isArray(i)||("function"==typeof i.entries&&(i=i.entries()),i=k(i));for(var a=0;a<i.length;a++)this[t=i[a]]=ge(e[t],de[t]);var s=oe;Array.isArray(s)||("function"==typeof s.entries&&(s=s.entries()),s=k(s));for(var u=0;u<s.length;u++)this[t=s[u]]=ge(e[t],de[t]);var o=ae;Array.isArray(o)||("function"==typeof o.entries&&(o=o.entries()),o=k(o));for(var f=0;f<o.length;f++)this[t=o[f]]=new le(t,de[t],e[t],this);var c=se;Array.isArray(c)||("function"==typeof c.entries&&(c=c.entries()),c=k(c));for(var h=0;h<c.length;h++)this[t=c[h]]=new le(t,de[t],e[t],this.tiff);this.setupGlobalFilters(e.pick,e.skip,se,ue),!0===e.tiff?this.batchEnableWithBool(se,!0):!1===e.tiff?this.batchEnableWithUserValue(se,e):Array.isArray(e.tiff)?this.setupGlobalFilters(e.tiff,void 0,se):"object"==typeof e.tiff&&this.setupGlobalFilters(e.tiff.pick,e.tiff.skip,se)}},{key:"batchEnableWithBool",value:function(e,t){var n=e;Array.isArray(n)||("function"==typeof n.entries&&(n=n.entries()),n=k(n));for(var r=0;r<n.length;r++){this[n[r]].enabled=t}}},{key:"batchEnableWithUserValue",value:function(e,t){var n=e;Array.isArray(n)||("function"==typeof n.entries&&(n=n.entries()),n=k(n));for(var r=0;r<n.length;r++){var i=n[r],a=t[i];this[i].enabled=!1!==a&&void 0!==a}}},{key:"setupGlobalFilters",value:function(e,t,n){var r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:n;if(e&&e.length){var i=r;Array.isArray(i)||("function"==typeof i.entries&&(i=i.entries()),i=k(i));for(var a=0;a<i.length;a++){var s=i[a];this[s].enabled=!1}var u=ye(e,n),o=u;Array.isArray(o)||("function"==typeof o.entries&&(o=o.entries()),o=k(o));for(var f=0;f<o.length;f++){var c=o[f],h=c[0],l=c[1];ke(this[h].pick,l),this[h].enabled=!0}}else if(t&&t.length){var d=ye(t,n),v=d;Array.isArray(v)||("function"==typeof v.entries&&(v=v.entries()),v=k(v));for(var p=0;p<v.length;p++){var y=v[p],g=y[0],m=y[1];ke(this[g].skip,m)}}}},{key:"filterNestedSegmentTags",value:function(){var e=this.ifd0,t=this.exif,n=this.xmp,r=this.iptc,i=this.icc;this.makerNote?t.deps.add(37500):t.skip.add(37500),this.userComment?t.deps.add(37510):t.skip.add(37510),n.enabled||e.skip.add(700),r.enabled||e.skip.add(33723),i.enabled||e.skip.add(34675)}},{key:"traverseTiffDependencyTree",value:function(){var e=this,t=this.ifd0,n=this.exif,r=this.gps;this.interop.needed&&(n.deps.add(40965),t.deps.add(40965)),n.needed&&t.deps.add(34665),r.needed&&t.deps.add(34853),this.tiff.enabled=se.some((function(t){return!0===e[t].enabled}))||this.makerNote||this.userComment;var i=se;Array.isArray(i)||("function"==typeof i.entries&&(i=i.entries()),i=k(i));for(var a=0;a<i.length;a++){this[i[a]].finalizeFilters()}}},{key:"checkLoadedPlugins",value:function(){var e=ae;Array.isArray(e)||("function"==typeof e.entries&&(e=e.entries()),e=k(e));for(var t=0;t<e.length;t++){var n=e[t];this[n].enabled&&!N.has(n)&&E("segment parser",n)}}},{key:"onlyTiff",get:function(){var e=this;return!ie.map((function(t){return e[t].enabled})).some((function(e){return!0===e}))&&this.tiff.enabled}}]),n}(he);function ye(e,t){var n,r,i,a=[],s=t;Array.isArray(s)||("function"==typeof s.entries&&(s=s.entries()),s=k(s));for(var u=0;u<s.length;u++){r=s[u],n=[];var o=ee.get(r);Array.isArray(o)||("function"==typeof o.entries&&(o=o.entries()),o=k(o));for(var f=0;f<o.length;f++)i=o[f],(e.includes(i[0])||e.includes(i[1]))&&n.push(i[0]);n.length&&a.push([r,n])}return a}function ge(e,t){return void 0!==e?e:void 0!==t?t:void 0}function ke(e,t){var n=t;Array.isArray(n)||("function"==typeof n.entries&&(n=n.entries()),n=k(n));for(var r=0;r<n.length;r++){var i=n[r];e.add(i)}}function me(e,t,n){return n?t?t(e):e:(e&&e.then||(e=Promise.resolve(e)),t?e.then(t):e)}function be(e,t){var n=e();return n&&n.then?n.then(t):t(n)}function Ae(){}i(pe,"default",de);var we=function(){function e(n){t(this,e),i(this,"parsers",{}),this.options=pe.useCached(n)}return r(e,[{key:"setup",value:function(){if(!this.fileParser){var e=this.file,t=e.getUint16(0),n=M;Array.isArray(n)||("function"==typeof n.entries&&(n=n.entries()),n=k(n));for(var r=0;r<n.length;r++){var i=n[r],a=i[0],s=i[1];if(s.canHandle(e,t))return this.fileParser=new s(this.options,this.file,this.parsers),e[a]=!0}I("Unknown file format")}}},{key:"read",value:function(e){try{var t=this;return me(function(e,t){return"string"==typeof e?q(e,t):U&&!x&&e instanceof HTMLImageElement?q(e.src,t):e instanceof Uint8Array||e instanceof ArrayBuffer||e instanceof DataView?new F(e):U&&e instanceof Blob?J(e,t,"blob",H):void I("Invalid input argument")}(e,t.options),(function(e){t.file=e}))}catch(e){return Promise.reject(e)}}},{key:"parse",value:function(){try{var e=this;return e.setup(),me(e.fileParser.parse(),(function(){var t,n={},r=[],i=v(e.parsers).map((t=function(t){var i;return be((function(){return e.options.silentErrors?(n=function(e,t){try{var n=e()}catch(e){return t(e)}return n&&n.then?n.then(void 0,t):n}((function(){return me(t.parse(),(function(e){i=e}))}),(function(e){r.push(e)})),a=function(){r.push.apply(r,t.errors)},n&&n.then?n.then(a):a(n)):me(t.parse(),(function(e){i=e}));var n,a}),(function(){t.assignToOutput(n,i)}))},function(){for(var e=[],n=0;n<arguments.length;n++)e[n]=arguments[n];try{return Promise.resolve(t.apply(this,e))}catch(e){return Promise.reject(e)}}));return me(Promise.all(i),(function(){return e.options.silentErrors&&r.length>0&&(n.errors=r),e.file.close&&e.file.close(),V(t=n)?void 0:t;var t}))}))}catch(e){return Promise.reject(e)}}},{key:"extractThumbnail",value:function(){try{var e=this;e.setup();var t,n=e.options,r=e.file,i=N.get("tiff",n);return be((function(){if(!r.tiff)return function(e){var t=e();if(t&&t.then)return t.then(Ae)}((function(){if(r.jpeg)return me(e.fileParser.getOrFindSegment("tiff"),(function(e){t=e}))}));t={start:0,type:"tiff"}}),(function(){if(void 0!==t)return me(e.fileParser.ensureSegmentChunk(t),(function(t){return me((e.parsers.tiff=new i(t,n,r)).extractThumbnail(),(function(e){return r.close&&r.close(),e}))}))}))}catch(e){return Promise.reject(e)}}}]),e}();var Oe,Se=(Oe=function(e,t){var n,r,i,a=new we(t);return n=a.read(e),r=function(){return a.parse()},i?r?r(n):n:(n&&n.then||(n=Promise.resolve(n)),r?n.then(r):n)},function(){for(var e=[],t=0;t<arguments.length;t++)e[t]=arguments[t];try{return Promise.resolve(Oe.apply(this,e))}catch(e){return Promise.reject(e)}}),Pe=Object.freeze({__proto__:null,parse:Se,Exifr:we,fileParsers:M,segmentParsers:N,fileReaders:R,tagKeys:ee,tagValues:te,tagRevivers:ne,createDictionary:Z,extendDictionary:$,fetchUrlAsArrayBuffer:X,readBlobAsArrayBuffer:H,chunkedProps:re,otherSegments:ie,segments:ae,tiffBlocks:se,segmentsAndBlocks:ue,tiffExtractables:oe,inheritables:fe,allFormatters:ce,Options:pe});function Ue(){}var xe=function(){function e(n,r,a){var s=this;t(this,e),i(this,"ensureSegmentChunk",function(e){return function(){for(var t=[],n=0;n<arguments.length;n++)t[n]=arguments[n];try{return Promise.resolve(e.apply(this,t))}catch(e){return Promise.reject(e)}}}((function(e){var t,n,r,i=e.start,a=e.size||65536;return t=function(){if(s.file.chunked)return function(e){var t=e();if(t&&t.then)return t.then(Ue)}((function(){if(!s.file.available(i,a))return function(e){if(e&&e.then)return e.then(Ue)}(function(e,t){try{var n=e()}catch(e){return t(e)}return n&&n.then?n.then(void 0,t):n}((function(){return t=s.file.readChunk(i,a),n=function(t){e.chunk=t},r?n?n(t):t:(t&&t.then||(t=Promise.resolve(t)),n?t.then(n):t);var t,n,r}),(function(t){I("Couldn't read segment: ".concat(JSON.stringify(e),". ").concat(t.message))})));e.chunk=s.file.subarray(i,a)}));s.file.byteLength>i+a?e.chunk=s.file.subarray(i,a):void 0===e.size?e.chunk=s.file.subarray(i):I("Segment unreachable: "+JSON.stringify(e))},n=function(){return e.chunk},(r=t())&&r.then?r.then(n):n(r)}))),this.extendOptions&&this.extendOptions(n),this.options=n,this.file=r,this.parsers=a}return r(e,[{key:"createParser",value:function(e,t){var n=new(N.get(e))(t,this.options,this.file);return this.parsers[e]=n}}]),e}(),Ce=function(){function e(n){var r=this,a=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},s=arguments.length>2?arguments[2]:void 0;t(this,e),i(this,"errors",[]),i(this,"raw",O()),i(this,"handleError",(function(e){if(!r.options.silentErrors)throw e;r.errors.push(e.message)})),this.chunk=this.normalizeInput(n),this.file=s,this.type=this.constructor.type,this.globalOptions=this.options=a,this.localOptions=a[this.type],this.canTranslate=this.localOptions&&this.localOptions.translate}return r(e,[{key:"normalizeInput",value:function(e){return e instanceof F?e:new F(e)}}],[{key:"findPosition",value:function(e,t){var n=e.getUint16(t+2)+2,r="function"==typeof this.headerLength?this.headerLength(e,t,n):this.headerLength,i=t+r,a=n-r;return{offset:t,length:n,headerLength:r,start:i,size:a,end:i+a}}},{key:"parse",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},n=new pe(i({},this.type,t)),r=new this(e,n);return r.parse()}}]),r(e,[{key:"translate",value:function(){this.canTranslate&&(this.translated=this.translateBlock(this.raw,this.type))}},{key:"translateBlock",value:function(e,t){var n=ne.get(t),r=te.get(t),i=ee.get(t),a=this.options[t],s=a.reviveValues&&!!n,u=a.translateValues&&!!r,o=a.translateKeys&&!!i,f={},c=e;Array.isArray(c)||("function"==typeof c.entries&&(c=c.entries()),c=k(c));for(var h=0;h<c.length;h++){var l=c[h],d=l[0],v=l[1];s&&n.has(d)?v=n.get(d)(v):u&&r.has(d)&&(v=this.translateValue(v,r.get(d))),o&&i.has(d)&&(d=i.get(d)||d),f[d]=v}return f}},{key:"translateValue",value:function(e,t){return t[e]||e}},{key:"assignToOutput",value:function(e,t){this.assignObjectToOutput(e,this.constructor.type,t)}},{key:"assignObjectToOutput",value:function(e,t,n){if(this.globalOptions.mergeOutput)return y(e,n);e[t]?y(e[t],n):e[t]=n}},{key:"output",get:function(){return this.translated?this.translated:this.raw?g(this.raw):void 0}}]),e}();function _e(e,t,n){return n?t?t(e):e:(e&&e.then||(e=Promise.resolve(e)),t?e.then(t):e)}i(Ce,"headerLength",4),i(Ce,"type",void 0),i(Ce,"multiSegment",!1),i(Ce,"canHandle",(function(){return!1}));function je(){}function Be(e,t){if(!t)return e&&e.then?e.then(je):Promise.resolve()}function Ve(e){var t=e();if(t&&t.then)return t.then(je)}function Ie(e,t){var n=e();return n&&n.then?n.then(t):t(n)}function ze(e,t,n){if(!e.s){if(n instanceof Le){if(!n.s)return void(n.o=ze.bind(null,e,t));1&t&&(t=n.s),n=n.v}if(n&&n.then)return void n.then(ze.bind(null,e,t),ze.bind(null,e,2));e.s=t,e.v=n;var r=e.o;r&&r(e)}}var Le=function(){function e(){}return e.prototype.then=function(t,n){var r=new e,i=this.s;if(i){var a=1&i?t:n;if(a){try{ze(r,1,a(this.v))}catch(e){ze(r,2,e)}return r}return this}return this.o=function(e){try{var i=e.v;1&e.s?ze(r,1,t?t(i):i):n?ze(r,1,n(i)):ze(r,2,i)}catch(e){ze(r,2,e)}},r},e}();function Te(e){return e instanceof Le&&1&e.s}function Fe(e,t,n){for(var r;;){var i=e();if(Te(i)&&(i=i.v),!i)return a;if(i.then){r=0;break}var a=n();if(a&&a.then){if(!Te(a)){r=1;break}a=a.s}if(t){var s=t();if(s&&s.then&&!Te(s)){r=2;break}}}var u=new Le,o=ze.bind(null,u,2);return(0===r?i.then(c):1===r?a.then(f):s.then(h)).then(void 0,o),u;function f(r){a=r;do{if(t&&(s=t())&&s.then&&!Te(s))return void s.then(h).then(void 0,o);if(!(i=e())||Te(i)&&!i.v)return void ze(u,1,a);if(i.then)return void i.then(c).then(void 0,o);Te(a=n())&&(a=a.v)}while(!a||!a.then);a.then(f).then(void 0,o)}function c(e){e?(a=n())&&a.then?a.then(f).then(void 0,o):f(a):ze(u,1,a)}function h(){(i=e())?i.then?i.then(c).then(void 0,o):c(i):ze(u,1,a)}}function Ee(e){return 192===e||194===e||196===e||219===e||221===e||218===e||254===e}function De(e){return e>=224&&e<=239}function Me(e,t){var n=N;Array.isArray(n)||("function"==typeof n.entries&&(n=n.entries()),n=k(n));for(var r=0;r<n.length;r++){var i=n[r],a=i[0];if(i[1].canHandle(e,t))return a}}var Ne=function(e){function n(){var e,r;t(this,n);for(var a=arguments.length,u=new Array(a),o=0;o<a;o++)u[o]=arguments[o];return i(h(r=l(this,(e=s(n)).call.apply(e,[this].concat(u)))),"appSegments",[]),i(h(r),"jpegSegments",[]),i(h(r),"unknownSegments",[]),r}return a(n,e),r(n,[{key:"parse",value:function(){try{var e=this;return _e(e.findAppSegments(),(function(){return _e(e.readSegments(),(function(){e.mergeMultiSegments(),e.createParsers()}))}))}catch(e){return Promise.reject(e)}}},{key:"readSegments",value:function(){try{var e=this.appSegments.map(this.ensureSegmentChunk);return Be(Promise.all(e))}catch(e){return Promise.reject(e)}}},{key:"setupSegmentFinderArgs",value:function(e){var t=this;!0===e?(this.findAll=!0,this.wanted=w(N.keyList())):(e=void 0===e?N.keyList().filter((function(e){return t.options[e].enabled})):e.filter((function(e){return t.options[e].enabled&&N.has(e)})),this.findAll=!1,this.remaining=w(e),this.wanted=w(e)),this.unfinishedMultiSegment=!1}},{key:"findAppSegments",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:0,t=arguments.length>1?arguments[1]:void 0;try{var n=this;n.setupSegmentFinderArgs(t);var r=n.file,i=n.findAll,a=n.wanted,s=n.remaining;return Ie((function(){if(!i&&n.file.chunked)return i=k(a).some((function(e){var t=N.get(e),r=n.options[e];return t.multiSegment&&r.multiSegment})),Ve((function(){if(i)return Be(n.file.readWhole())}))}),(function(){var t=!1;if(e=n._findAppSegments(e,r.byteLength,i,a,s),!n.options.onlyTiff)return function(){if(r.chunked){var i=!1;return Fe((function(){return!t&&s.size>0&&!i&&(!!r.canReadNextChunk||!!n.unfinishedMultiSegment)}),void 0,(function(){var a=r.nextChunkOffset,s=n.appSegments.some((function(e){return!n.file.available(e.offset||e.start,e.length||e.size)}));return Ie((function(){return e>a&&!s?_e(r.readNextChunk(e),(function(e){i=!e})):_e(r.readNextChunk(a),(function(e){i=!e}))}),(function(){void 0===(e=n._findAppSegments(e,r.byteLength))&&(t=!0)}))}))}}()}))}catch(e){return Promise.reject(e)}}},{key:"_findAppSegments",value:function(e,t){t-=2;for(var n,r,i,a,s,u,o=this.file,f=this.findAll,c=this.wanted,h=this.remaining,l=this.options;e<t;e++)if(255===o.getUint8(e))if(De(n=o.getUint8(e+1))){if(r=o.getUint16(e+2),(i=Me(o,e))&&c.has(i)&&(s=(a=N.get(i)).findPosition(o,e),u=l[i],s.type=i,this.appSegments.push(s),!f&&(a.multiSegment&&u.multiSegment?(this.unfinishedMultiSegment=s.chunkNumber<s.chunkCount,this.unfinishedMultiSegment||h.delete(i)):h.delete(i),0===h.size)))break;l.recordUnknownSegments&&((s=Ce.findPosition(o,e)).marker=n,this.unknownSegments.push(s)),e+=r+1}else if(Ee(n)){if(r=o.getUint16(e+2),218===n&&!1!==l.stopAfterSos)return;l.recordJpegSegments&&this.jpegSegments.push({offset:e,length:r,marker:n}),e+=r+1}return e}},{key:"mergeMultiSegments",value:function(){var e=this;if(this.appSegments.some((function(e){return e.multiSegment}))){var t=function(e,t){for(var n,r,i,a=O(),s=0;s<e.length;s++)n=e[s],r=n[t],a.has(r)?i=a.get(r):a.set(r,i=[]),i.push(n);return k(a)}(this.appSegments,"type");this.mergedAppSegments=t.map((function(t){var n=t[0],r=t[1],i=N.get(n,e.options);return i.handleMultiSegments?{type:n,chunk:i.handleMultiSegments(r)}:r[0]}))}}},{key:"createParsers",value:function(){try{var e=this.mergedAppSegments||this.appSegments;Array.isArray(e)||("function"==typeof e.entries&&(e=e.entries()),e=k(e));for(var t=0;t<e.length;t++){var n=e[t],r=n.type,i=n.chunk;if(this.options[r].enabled){var a=this.parsers[r];if(a&&a.append);else if(!a){var s=new(N.get(r,this.options))(i,this.options,this.file);this.parsers[r]=s}}}return _e()}catch(e){return Promise.reject(e)}}},{key:"getSegment",value:function(e){return this.appSegments.find((function(t){return t.type===e}))}},{key:"getOrFindSegment",value:function(e){try{var t=this,n=t.getSegment(e);return Ie((function(){if(void 0===n)return _e(t.findAppSegments(0,[e]),(function(){n=t.getSegment(e)}))}),(function(){return n}))}catch(e){return Promise.reject(e)}}}],[{key:"canHandle",value:function(e,t){return 65496===t}}]),n}(xe);function Re(){}i(Ne,"type","jpeg"),M.set("jpeg",Ne);function We(e,t){if(!t)return e&&e.then?e.then(Re):Promise.resolve()}function Ke(e,t){var n=e();return n&&n.then?n.then(t):t(n)}var He=[void 0,1,1,2,4,8,1,1,2,4,8,4,8,4];var Xe=function(e){function n(){return t(this,n),l(this,s(n).apply(this,arguments))}return a(n,e),r(n,[{key:"parse",value:function(){try{var e=this;e.parseHeader();var t=e.options;return Ke((function(){if(t.ifd0.enabled)return We(e.parseIfd0Block())}),(function(){return Ke((function(){if(t.exif.enabled)return We(e.safeParse("parseExifBlock"))}),(function(){return Ke((function(){if(t.gps.enabled)return We(e.safeParse("parseGpsBlock"))}),(function(){return Ke((function(){if(t.interop.enabled)return We(e.safeParse("parseInteropBlock"))}),(function(){return Ke((function(){if(t.ifd1.enabled)return We(e.safeParse("parseThumbnailBlock"))}),(function(){return e.createOutput()}))}))}))}))}))}catch(e){return Promise.reject(e)}}},{key:"safeParse",value:function(e){var t=this[e]();return void 0!==t.catch&&(t=t.catch(this.handleError)),t}},{key:"findIfd0Offset",value:function(){void 0===this.ifd0Offset&&(this.ifd0Offset=this.chunk.getUint32(4))}},{key:"findIfd1Offset",value:function(){if(void 0===this.ifd1Offset){this.findIfd0Offset();var e=this.chunk.getUint16(this.ifd0Offset),t=this.ifd0Offset+2+12*e;this.ifd1Offset=this.chunk.getUint32(t)}}},{key:"parseBlock",value:function(e,t){var n=O();return this[t]=n,this.parseTags(e,t,n),n}},{key:"parseIfd0Block",value:function(){try{var e=this;if(e.ifd0)return;var t=e.file;return e.findIfd0Offset(),e.ifd0Offset<8&&I("Malformed EXIF data"),!t.chunked&&e.ifd0Offset>t.byteLength&&I("IFD0 offset points to outside of file.\nthis.ifd0Offset: ".concat(e.ifd0Offset,", file.byteLength: ").concat(t.byteLength)),Ke((function(){if(t.tiff)return We(t.ensureChunk(e.ifd0Offset,z(e.options)))}),(function(){var t=e.parseBlock(e.ifd0Offset,"ifd0");if(0!==t.size)return e.exifOffset=t.get(34665),e.interopOffset=t.get(40965),e.gpsOffset=t.get(34853),e.xmp=t.get(700),e.iptc=t.get(33723),e.icc=t.get(34675),e.options.sanitize&&(t.delete(34665),t.delete(40965),t.delete(34853),t.delete(700),t.delete(33723),t.delete(34675)),t}))}catch(e){return Promise.reject(e)}}},{key:"parseExifBlock",value:function(){try{var e=this;if(e.exif)return;return Ke((function(){if(!e.ifd0)return We(e.parseIfd0Block())}),(function(){if(void 0!==e.exifOffset)return Ke((function(){if(e.file.tiff)return We(e.file.ensureChunk(e.exifOffset,z(e.options)))}),(function(){var t=e.parseBlock(e.exifOffset,"exif");return e.interopOffset||(e.interopOffset=t.get(40965)),e.makerNote=t.get(37500),e.userComment=t.get(37510),e.options.sanitize&&(t.delete(40965),t.delete(37500),t.delete(37510)),e.unpack(t,41728),e.unpack(t,41729),t}))}))}catch(e){return Promise.reject(e)}}},{key:"unpack",value:function(e,t){var n=e.get(t);n&&1===n.length&&e.set(t,n[0])}},{key:"parseGpsBlock",value:function(){try{var e=this;if(e.gps)return;return Ke((function(){if(!e.ifd0)return We(e.parseIfd0Block())}),(function(){if(void 0!==e.gpsOffset){var t=e.parseBlock(e.gpsOffset,"gps");return t&&t.has(2)&&t.has(4)&&(t.set("latitude",Ye.apply(void 0,t.get(2).concat([t.get(1)]))),t.set("longitude",Ye.apply(void 0,t.get(4).concat([t.get(3)])))),t}}))}catch(e){return Promise.reject(e)}}},{key:"parseInteropBlock",value:function(){try{var e=this;if(e.interop)return;return Ke((function(){if(!e.ifd0)return We(e.parseIfd0Block())}),(function(){return Ke((function(){if(void 0===e.interopOffset&&!e.exif)return We(e.parseExifBlock())}),(function(){if(void 0!==e.interopOffset)return e.parseBlock(e.interopOffset,"interop")}))}))}catch(e){return Promise.reject(e)}}},{key:"parseThumbnailBlock",value:function(){var e=arguments.length>0&&void 0!==arguments[0]&&arguments[0];try{var t=this;if(t.ifd1||t.ifd1Parsed)return;if(t.options.mergeOutput&&!e)return;return t.findIfd1Offset(),t.ifd1Offset>0&&(t.parseBlock(t.ifd1Offset,"ifd1"),t.ifd1Parsed=!0),t.ifd1}catch(e){return Promise.reject(e)}}},{key:"extractThumbnail",value:function(){try{var e=this;return e.headerParsed||e.parseHeader(),Ke((function(){if(!e.ifd1Parsed)return We(e.parseThumbnailBlock(!0))}),(function(){if(void 0!==e.ifd1){var t=e.ifd1.get(513),n=e.ifd1.get(514);return e.chunk.getUint8Array(t,n)}}))}catch(e){return Promise.reject(e)}}},{key:"createOutput",value:function(){var e,t,n,r={},i=se;Array.isArray(i)||("function"==typeof i.entries&&(i=i.entries()),i=k(i));for(var a=0;a<i.length;a++)if(!V(e=this[t=i[a]]))if(n=this.canTranslate?this.translateBlock(e,t):g(e),this.options.mergeOutput){if("ifd1"===t)continue;y(r,n)}else r[t]=n;return this.makerNote&&(r.makerNote=this.makerNote),this.userComment&&(r.userComment=this.userComment),r}},{key:"assignToOutput",value:function(e,t){if(this.globalOptions.mergeOutput)y(e,t);else{var n=p(t);Array.isArray(n)||("function"==typeof n.entries&&(n=n.entries()),n=k(n));for(var r=0;r<n.length;r++){var i=n[r],a=i[0],s=i[1];this.assignObjectToOutput(e,a,s)}}}},{key:"image",get:function(){return this.ifd0}},{key:"thumbnail",get:function(){return this.ifd1}}],[{key:"canHandle",value:function(e,t){return 225===e.getUint8(t+1)&&1165519206===e.getUint32(t+4)&&0===e.getUint16(t+8)}}]),n}(function(e){function n(){return t(this,n),l(this,s(n).apply(this,arguments))}return a(n,e),r(n,[{key:"parseHeader",value:function(){var e=this.chunk.getUint16();18761===e?this.le=!0:19789===e&&(this.le=!1),this.chunk.le=this.le,this.headerParsed=!0}},{key:"parseTags",value:function(e,t){var n=arguments.length>2&&void 0!==arguments[2]?arguments[2]:O(),r=this.options[t],i=r.pick,a=r.skip,s=(i=w(i)).size>0,u=0===a.size,o=this.chunk.getUint16(e);e+=2;for(var f=0;f<o;f++){var c=this.chunk.getUint16(e);if(s){if(i.has(c)&&(n.set(c,this.parseTag(e,c,t)),i.delete(c),0===i.size))break}else!u&&a.has(c)||n.set(c,this.parseTag(e,c,t));e+=12}return n}},{key:"parseTag",value:function(e,t,n){var r,i=this.chunk,a=i.getUint16(e+2),s=i.getUint32(e+4),u=He[a];if(u*s<=4?e+=8:e=i.getUint32(e+8),(a<1||a>13)&&I("Invalid TIFF value type. block: ".concat(n.toUpperCase(),", tag: ").concat(t.toString(16),", type: ").concat(a,", offset ").concat(e)),e>i.byteLength&&I("Invalid TIFF value offset. block: ".concat(n.toUpperCase(),", tag: ").concat(t.toString(16),", type: ").concat(a,", offset ").concat(e," is outside of chunk size ").concat(i.byteLength)),1===a)return i.getUint8Array(e,s);if(2===a)return""===(r=function(e){for(;e.endsWith("\0");)e=e.slice(0,-1);return e}(r=i.getString(e,s)).trim())?void 0:r;if(7===a)return i.getUint8Array(e,s);if(1===s)return this.parseTagValue(a,e);for(var o=new(function(e){switch(e){case 1:return Uint8Array;case 3:return Uint16Array;case 4:return Uint32Array;case 5:return Array;case 6:return Int8Array;case 8:return Int16Array;case 9:return Int32Array;case 10:return Array;case 11:return Float32Array;case 12:return Float64Array;default:return Array}}(a))(s),f=u,c=0;c<s;c++)o[c]=this.parseTagValue(a,e),e+=f;return o}},{key:"parseTagValue",value:function(e,t){var n=this.chunk;switch(e){case 1:return n.getUint8(t);case 3:return n.getUint16(t);case 4:return n.getUint32(t);case 5:return n.getUint32(t)/n.getUint32(t+4);case 6:return n.getInt8(t);case 8:return n.getInt16(t);case 9:return n.getInt32(t);case 10:return n.getInt32(t)/n.getInt32(t+4);case 11:return n.getFloat(t);case 12:return n.getDouble(t);case 13:return n.getUint32(t);default:I("Invalid tiff type ".concat(e))}}}]),n}(Ce));function Ye(e,t,n,r){var i=e+t/60+n/3600;return"S"!==r&&"W"!==r||(i*=-1),i}i(Xe,"type","tiff"),i(Xe,"headerLength",10),N.set("tiff",Xe);var Ge=Object.freeze({__proto__:null,default:Pe,parse:Se,Exifr:we,fileParsers:M,segmentParsers:N,fileReaders:R,tagKeys:ee,tagValues:te,tagRevivers:ne,createDictionary:Z,extendDictionary:$,fetchUrlAsArrayBuffer:X,readBlobAsArrayBuffer:H,chunkedProps:re,otherSegments:ie,segments:ae,tiffBlocks:se,segmentsAndBlocks:ue,tiffExtractables:oe,inheritables:fe,allFormatters:ce,Options:pe});function Je(e,t,n){return n?t?t(e):e:(e&&e.then||(e=Promise.resolve(e)),t?e.then(t):e)}function qe(e){return function(){for(var t=[],n=0;n<arguments.length;n++)t[n]=arguments[n];try{return Promise.resolve(e.apply(this,t))}catch(e){return Promise.reject(e)}}}var Qe=qe((function(e){var t=new we(rt);return Je(t.read(e),(function(){return Je(t.parse(),(function(e){if(e&&e.ifd0)return e.ifd0[274]}))}))})),Ze=qe((function(e){var t=new we(nt);return Je(t.read(e),(function(){return Je(t.parse(),(function(e){if(e&&e.gps){var t=e.gps;return{latitude:t.latitude,longitude:t.longitude}}}))}))})),$e=qe((function(e){return Je(this.thumbnail(e),(function(e){if(void 0!==e){var t=new Blob([e]);return URL.createObjectURL(t)}}))})),et=qe((function(e){var t=new we(it);return Je(t.read(e),(function(){return Je(t.extractThumbnail(),(function(e){return e&&j?_.from(e):e}))}))})),tt={ifd0:!1,ifd1:!1,exif:!1,gps:!1,interop:!1,sanitize:!1,reviveValues:!0,translateKeys:!1,translateValues:!1,mergeOutput:!1},nt=y({},tt,{firstChunkSize:4e4,gps:[1,2,3,4]}),rt=y({},tt,{firstChunkSize:4e4,ifd0:[274]}),it=y({},tt,{tiff:!1,ifd1:!0,mergeOutput:!1}),at={1:{dimensionSwapped:!1,scaleX:1,scaleY:1,deg:0,rad:0},2:{dimensionSwapped:!1,scaleX:-1,scaleY:1,deg:0,rad:0},3:{dimensionSwapped:!1,scaleX:1,scaleY:1,deg:180,rad:180*Math.PI/180},4:{dimensionSwapped:!1,scaleX:-1,scaleY:1,deg:180,rad:180*Math.PI/180},5:{dimensionSwapped:!0,scaleX:1,scaleY:-1,deg:90,rad:90*Math.PI/180},6:{dimensionSwapped:!0,scaleX:1,scaleY:1,deg:90,rad:90*Math.PI/180},7:{dimensionSwapped:!0,scaleX:1,scaleY:-1,deg:270,rad:270*Math.PI/180},8:{dimensionSwapped:!0,scaleX:1,scaleY:1,deg:270,rad:270*Math.PI/180}};if(e.rotateCanvas=!0,e.rotateCss=!0,"object"==typeof navigator){var st=navigator.userAgent;if(st.includes("iPad")||st.includes("iPhone")){var ut=st.match(/OS (\d+)_(\d+)/),ot=(ut[0],ut[1]),ft=ut[2],ct=Number(ot)+.1*Number(ft);e.rotateCanvas=ct<13.4,e.rotateCss=!1}if(st.includes("Chrome/")){var ht=st.match(/Chrome\/(\d+)/),lt=(ht[0],ht[1]);Number(lt)>=81&&(e.rotateCanvas=e.rotateCss=!1)}else if(st.includes("Firefox/")){var dt=st.match(/Firefox\/(\d+)/),vt=(dt[0],dt[1]);Number(vt)>=77&&(e.rotateCanvas=e.rotateCss=!1)}}function pt(){}var yt=function(e){function n(){var e,r;t(this,n);for(var a=arguments.length,u=new Array(a),o=0;o<a;o++)u[o]=arguments[o];return i(h(r=l(this,(e=s(n)).call.apply(e,[this].concat(u)))),"ranges",new gt),0!==r.byteLength&&r.ranges.add(0,r.byteLength),r}return a(n,e),r(n,[{key:"_tryExtend",value:function(e,t,n){if(0===e&&0===this.byteLength&&n){var r=new DataView(n.buffer||n,n.byteOffset,n.byteLength);this._swapDataView(r)}else{var i=e+t;if(i>this.byteLength){var a=this._extend(i).dataView;this._swapDataView(a)}}}},{key:"_extend",value:function(e){var t;t=j?_.allocUnsafe(e):new Uint8Array(e);var n=new DataView(t.buffer,t.byteOffset,t.byteLength);return t.set(new Uint8Array(this.buffer,this.byteOffset,this.byteLength),0),{uintView:t,dataView:n}}},{key:"subarray",value:function(e,t){var r=arguments.length>2&&void 0!==arguments[2]&&arguments[2];return t=t||this._lengthToEnd(e),r&&this._tryExtend(e,t),this.ranges.add(e,t),d(s(n.prototype),"subarray",this).call(this,e,t)}},{key:"set",value:function(e,t){var r=arguments.length>2&&void 0!==arguments[2]&&arguments[2];r&&this._tryExtend(t,e.byteLength,e);var i=d(s(n.prototype),"set",this).call(this,e,t);return this.ranges.add(t,i.byteLength),i}},{key:"ensureChunk",value:function(e,t){try{if(!this.chunked)return;if(this.ranges.available(e,t))return;return function(e,t){if(!t)return e&&e.then?e.then(pt):Promise.resolve()}(this.readChunk(e,t))}catch(e){return Promise.reject(e)}}},{key:"available",value:function(e,t){return this.ranges.available(e,t)}}]),n}(F),gt=function(){function e(){t(this,e),i(this,"list",[])}return r(e,[{key:"add",value:function(e,t){var n=e+t,r=this.list.filter((function(t){return kt(e,t.offset,n)||kt(e,t.end,n)}));if(r.length>0){e=Math.min.apply(Math,[e].concat(r.map((function(e){return e.offset})))),t=(n=Math.max.apply(Math,[n].concat(r.map((function(e){return e.end})))))-e;var i=r.shift();i.offset=e,i.length=t,i.end=n,this.list=this.list.filter((function(e){return!r.includes(e)}))}else this.list.push({offset:e,length:t,end:n})}},{key:"available",value:function(e,t){var n=e+t;return this.list.some((function(t){return t.offset<=e&&n<=t.end}))}},{key:"length",get:function(){return this.list.length}}]),e}();function kt(e,t,n){return e<=t&&t<=n}function mt(){}function bt(e,t){if(!t)return e&&e.then?e.then(mt):Promise.resolve()}function At(e,t,n){return n?t?t(e):e:(e&&e.then||(e=Promise.resolve(e)),t?e.then(t):e)}var wt=function(e){function n(){return t(this,n),l(this,s(n).apply(this,arguments))}return a(n,e),r(n,[{key:"readWhole",value:function(){try{var e=this;return e.chunked=!1,At(H(e.input),(function(t){e._swapArrayBuffer(t)}))}catch(e){return Promise.reject(e)}}},{key:"readChunked",value:function(){return this.chunked=!0,this.size=this.input.size,d(s(n.prototype),"readChunked",this).call(this)}},{key:"_readChunk",value:function(e,t){try{var n=this,r=t?e+t:void 0,i=n.input.slice(e,r);return At(H(i),(function(t){return n.set(t,e,!0)}))}catch(e){return Promise.reject(e)}}}]),n}(function(e){function n(e,r){var a;return t(this,n),i(h(a=l(this,s(n).call(this,0))),"chunksRead",0),a.input=e,a.options=r,a}return a(n,e),r(n,[{key:"readWhole",value:function(){try{return this.chunked=!1,bt(this.readChunk(this.nextChunkOffset))}catch(e){return Promise.reject(e)}}},{key:"readChunked",value:function(){try{return this.chunked=!0,bt(this.readChunk(0,this.options.firstChunkSize))}catch(e){return Promise.reject(e)}}},{key:"readNextChunk",value:function(e){try{if(void 0===e&&(e=this.nextChunkOffset),this.fullyRead)return this.chunksRead++,!1;var t=this.options.chunkSize;return n=this.readChunk(e,t),r=function(e){return!!e&&e.byteLength===t},i?r?r(n):n:(n&&n.then||(n=Promise.resolve(n)),r?n.then(r):n)}catch(e){return Promise.reject(e)}var n,r,i}},{key:"readChunk",value:function(e,t){try{if(this.chunksRead++,0===(t=this.safeWrapAddress(e,t)))return;return this._readChunk(e,t)}catch(e){return Promise.reject(e)}}},{key:"safeWrapAddress",value:function(e,t){return void 0!==this.size&&e+t>this.size?Math.max(0,this.size-e):t}},{key:"read",value:function(){return this.options.chunked?this.readChunked():this.readWhole()}},{key:"close",value:function(){}},{key:"nextChunkOffset",get:function(){if(0!==this.ranges.list.length)return this.ranges.list[0].length}},{key:"canReadNextChunk",get:function(){return this.chunksRead<this.options.chunkLimit}},{key:"fullyRead",get:function(){return void 0!==this.size&&this.nextChunkOffset===this.size}}]),n}(yt));R.set("blob",wt),e.Exifr=we,e.Options=pe,e.allFormatters=ce,e.chunkedProps=re,e.createDictionary=Z,e.default=Ge,e.disableAllOptions=tt,e.extendDictionary=$,e.fetchUrlAsArrayBuffer=X,e.fileParsers=M,e.fileReaders=R,e.gps=Ze,e.gpsOnlyOptions=nt,e.inheritables=fe,e.orientation=Qe,e.orientationOnlyOptions=rt,e.otherSegments=ie,e.parse=Se,e.readBlobAsArrayBuffer=H,e.rotation=function(t){return Je(Qe(t),(function(t){return y({canvas:e.rotateCanvas,css:e.rotateCss},at[t])}))},e.rotations=at,e.segmentParsers=N,e.segments=ae,e.segmentsAndBlocks=ue,e.tagKeys=ee,e.tagRevivers=ne,e.tagValues=te,e.thumbnail=et,e.thumbnailOnlyOptions=it,e.thumbnailUrl=$e,e.tiffBlocks=se,e.tiffExtractables=oe,Object.defineProperty(e,"__esModule",{value:!0})}));

  }).call(this)}).call(this,require('_process'),typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {},require("buffer").Buffer)
  },{"_process":59,"buffer":57}],46:[function(require,module,exports){
  (function (global){(function (){
  /**
   * lodash (Custom Build) <https://lodash.com/>
   * Build: `lodash modularize exports="npm" -o ./`
   * Copyright jQuery Foundation and other contributors <https://jquery.org/>
   * Released under MIT license <https://lodash.com/license>
   * Based on Underscore.js 1.8.3 <http://underscorejs.org/LICENSE>
   * Copyright Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
   */

  /** Used as the `TypeError` message for "Functions" methods. */
  var FUNC_ERROR_TEXT = 'Expected a function';

  /** Used as references for various `Number` constants. */
  var NAN = 0 / 0;

  /** `Object#toString` result references. */
  var symbolTag = '[object Symbol]';

  /** Used to match leading and trailing whitespace. */
  var reTrim = /^\s+|\s+$/g;

  /** Used to detect bad signed hexadecimal string values. */
  var reIsBadHex = /^[-+]0x[0-9a-f]+$/i;

  /** Used to detect binary string values. */
  var reIsBinary = /^0b[01]+$/i;

  /** Used to detect octal string values. */
  var reIsOctal = /^0o[0-7]+$/i;

  /** Built-in method references without a dependency on `root`. */
  var freeParseInt = parseInt;

  /** Detect free variable `global` from Node.js. */
  var freeGlobal = typeof global == 'object' && global && global.Object === Object && global;

  /** Detect free variable `self`. */
  var freeSelf = typeof self == 'object' && self && self.Object === Object && self;

  /** Used as a reference to the global object. */
  var root = freeGlobal || freeSelf || Function('return this')();

  /** Used for built-in method references. */
  var objectProto = Object.prototype;

  /**
   * Used to resolve the
   * [`toStringTag`](http://ecma-international.org/ecma-262/7.0/#sec-object.prototype.tostring)
   * of values.
   */
  var objectToString = objectProto.toString;

  /* Built-in method references for those with the same name as other `lodash` methods. */
  var nativeMax = Math.max,
      nativeMin = Math.min;

  /**
   * Gets the timestamp of the number of milliseconds that have elapsed since
   * the Unix epoch (1 January 1970 00:00:00 UTC).
   *
   * @static
   * @memberOf _
   * @since 2.4.0
   * @category Date
   * @returns {number} Returns the timestamp.
   * @example
   *
   * _.defer(function(stamp) {
   *   console.log(_.now() - stamp);
   * }, _.now());
   * // => Logs the number of milliseconds it took for the deferred invocation.
   */
  var now = function() {
    return root.Date.now();
  };

  /**
   * Creates a debounced function that delays invoking `func` until after `wait`
   * milliseconds have elapsed since the last time the debounced function was
   * invoked. The debounced function comes with a `cancel` method to cancel
   * delayed `func` invocations and a `flush` method to immediately invoke them.
   * Provide `options` to indicate whether `func` should be invoked on the
   * leading and/or trailing edge of the `wait` timeout. The `func` is invoked
   * with the last arguments provided to the debounced function. Subsequent
   * calls to the debounced function return the result of the last `func`
   * invocation.
   *
   * **Note:** If `leading` and `trailing` options are `true`, `func` is
   * invoked on the trailing edge of the timeout only if the debounced function
   * is invoked more than once during the `wait` timeout.
   *
   * If `wait` is `0` and `leading` is `false`, `func` invocation is deferred
   * until to the next tick, similar to `setTimeout` with a timeout of `0`.
   *
   * See [David Corbacho's article](https://css-tricks.com/debouncing-throttling-explained-examples/)
   * for details over the differences between `_.debounce` and `_.throttle`.
   *
   * @static
   * @memberOf _
   * @since 0.1.0
   * @category Function
   * @param {Function} func The function to debounce.
   * @param {number} [wait=0] The number of milliseconds to delay.
   * @param {Object} [options={}] The options object.
   * @param {boolean} [options.leading=false]
   *  Specify invoking on the leading edge of the timeout.
   * @param {number} [options.maxWait]
   *  The maximum time `func` is allowed to be delayed before it's invoked.
   * @param {boolean} [options.trailing=true]
   *  Specify invoking on the trailing edge of the timeout.
   * @returns {Function} Returns the new debounced function.
   * @example
   *
   * // Avoid costly calculations while the window size is in flux.
   * jQuery(window).on('resize', _.debounce(calculateLayout, 150));
   *
   * // Invoke `sendMail` when clicked, debouncing subsequent calls.
   * jQuery(element).on('click', _.debounce(sendMail, 300, {
   *   'leading': true,
   *   'trailing': false
   * }));
   *
   * // Ensure `batchLog` is invoked once after 1 second of debounced calls.
   * var debounced = _.debounce(batchLog, 250, { 'maxWait': 1000 });
   * var source = new EventSource('/stream');
   * jQuery(source).on('message', debounced);
   *
   * // Cancel the trailing debounced invocation.
   * jQuery(window).on('popstate', debounced.cancel);
   */
  function debounce(func, wait, options) {
    var lastArgs,
        lastThis,
        maxWait,
        result,
        timerId,
        lastCallTime,
        lastInvokeTime = 0,
        leading = false,
        maxing = false,
        trailing = true;

    if (typeof func != 'function') {
      throw new TypeError(FUNC_ERROR_TEXT);
    }
    wait = toNumber(wait) || 0;
    if (isObject(options)) {
      leading = !!options.leading;
      maxing = 'maxWait' in options;
      maxWait = maxing ? nativeMax(toNumber(options.maxWait) || 0, wait) : maxWait;
      trailing = 'trailing' in options ? !!options.trailing : trailing;
    }

    function invokeFunc(time) {
      var args = lastArgs,
          thisArg = lastThis;

      lastArgs = lastThis = undefined;
      lastInvokeTime = time;
      result = func.apply(thisArg, args);
      return result;
    }

    function leadingEdge(time) {
      // Reset any `maxWait` timer.
      lastInvokeTime = time;
      // Start the timer for the trailing edge.
      timerId = setTimeout(timerExpired, wait);
      // Invoke the leading edge.
      return leading ? invokeFunc(time) : result;
    }

    function remainingWait(time) {
      var timeSinceLastCall = time - lastCallTime,
          timeSinceLastInvoke = time - lastInvokeTime,
          result = wait - timeSinceLastCall;

      return maxing ? nativeMin(result, maxWait - timeSinceLastInvoke) : result;
    }

    function shouldInvoke(time) {
      var timeSinceLastCall = time - lastCallTime,
          timeSinceLastInvoke = time - lastInvokeTime;

      // Either this is the first call, activity has stopped and we're at the
      // trailing edge, the system time has gone backwards and we're treating
      // it as the trailing edge, or we've hit the `maxWait` limit.
      return (lastCallTime === undefined || (timeSinceLastCall >= wait) ||
        (timeSinceLastCall < 0) || (maxing && timeSinceLastInvoke >= maxWait));
    }

    function timerExpired() {
      var time = now();
      if (shouldInvoke(time)) {
        return trailingEdge(time);
      }
      // Restart the timer.
      timerId = setTimeout(timerExpired, remainingWait(time));
    }

    function trailingEdge(time) {
      timerId = undefined;

      // Only invoke if we have `lastArgs` which means `func` has been
      // debounced at least once.
      if (trailing && lastArgs) {
        return invokeFunc(time);
      }
      lastArgs = lastThis = undefined;
      return result;
    }

    function cancel() {
      if (timerId !== undefined) {
        clearTimeout(timerId);
      }
      lastInvokeTime = 0;
      lastArgs = lastCallTime = lastThis = timerId = undefined;
    }

    function flush() {
      return timerId === undefined ? result : trailingEdge(now());
    }

    function debounced() {
      var time = now(),
          isInvoking = shouldInvoke(time);

      lastArgs = arguments;
      lastThis = this;
      lastCallTime = time;

      if (isInvoking) {
        if (timerId === undefined) {
          return leadingEdge(lastCallTime);
        }
        if (maxing) {
          // Handle invocations in a tight loop.
          timerId = setTimeout(timerExpired, wait);
          return invokeFunc(lastCallTime);
        }
      }
      if (timerId === undefined) {
        timerId = setTimeout(timerExpired, wait);
      }
      return result;
    }
    debounced.cancel = cancel;
    debounced.flush = flush;
    return debounced;
  }

  /**
   * Creates a throttled function that only invokes `func` at most once per
   * every `wait` milliseconds. The throttled function comes with a `cancel`
   * method to cancel delayed `func` invocations and a `flush` method to
   * immediately invoke them. Provide `options` to indicate whether `func`
   * should be invoked on the leading and/or trailing edge of the `wait`
   * timeout. The `func` is invoked with the last arguments provided to the
   * throttled function. Subsequent calls to the throttled function return the
   * result of the last `func` invocation.
   *
   * **Note:** If `leading` and `trailing` options are `true`, `func` is
   * invoked on the trailing edge of the timeout only if the throttled function
   * is invoked more than once during the `wait` timeout.
   *
   * If `wait` is `0` and `leading` is `false`, `func` invocation is deferred
   * until to the next tick, similar to `setTimeout` with a timeout of `0`.
   *
   * See [David Corbacho's article](https://css-tricks.com/debouncing-throttling-explained-examples/)
   * for details over the differences between `_.throttle` and `_.debounce`.
   *
   * @static
   * @memberOf _
   * @since 0.1.0
   * @category Function
   * @param {Function} func The function to throttle.
   * @param {number} [wait=0] The number of milliseconds to throttle invocations to.
   * @param {Object} [options={}] The options object.
   * @param {boolean} [options.leading=true]
   *  Specify invoking on the leading edge of the timeout.
   * @param {boolean} [options.trailing=true]
   *  Specify invoking on the trailing edge of the timeout.
   * @returns {Function} Returns the new throttled function.
   * @example
   *
   * // Avoid excessively updating the position while scrolling.
   * jQuery(window).on('scroll', _.throttle(updatePosition, 100));
   *
   * // Invoke `renewToken` when the click event is fired, but not more than once every 5 minutes.
   * var throttled = _.throttle(renewToken, 300000, { 'trailing': false });
   * jQuery(element).on('click', throttled);
   *
   * // Cancel the trailing throttled invocation.
   * jQuery(window).on('popstate', throttled.cancel);
   */
  function throttle(func, wait, options) {
    var leading = true,
        trailing = true;

    if (typeof func != 'function') {
      throw new TypeError(FUNC_ERROR_TEXT);
    }
    if (isObject(options)) {
      leading = 'leading' in options ? !!options.leading : leading;
      trailing = 'trailing' in options ? !!options.trailing : trailing;
    }
    return debounce(func, wait, {
      'leading': leading,
      'maxWait': wait,
      'trailing': trailing
    });
  }

  /**
   * Checks if `value` is the
   * [language type](http://www.ecma-international.org/ecma-262/7.0/#sec-ecmascript-language-types)
   * of `Object`. (e.g. arrays, functions, objects, regexes, `new Number(0)`, and `new String('')`)
   *
   * @static
   * @memberOf _
   * @since 0.1.0
   * @category Lang
   * @param {*} value The value to check.
   * @returns {boolean} Returns `true` if `value` is an object, else `false`.
   * @example
   *
   * _.isObject({});
   * // => true
   *
   * _.isObject([1, 2, 3]);
   * // => true
   *
   * _.isObject(_.noop);
   * // => true
   *
   * _.isObject(null);
   * // => false
   */
  function isObject(value) {
    var type = typeof value;
    return !!value && (type == 'object' || type == 'function');
  }

  /**
   * Checks if `value` is object-like. A value is object-like if it's not `null`
   * and has a `typeof` result of "object".
   *
   * @static
   * @memberOf _
   * @since 4.0.0
   * @category Lang
   * @param {*} value The value to check.
   * @returns {boolean} Returns `true` if `value` is object-like, else `false`.
   * @example
   *
   * _.isObjectLike({});
   * // => true
   *
   * _.isObjectLike([1, 2, 3]);
   * // => true
   *
   * _.isObjectLike(_.noop);
   * // => false
   *
   * _.isObjectLike(null);
   * // => false
   */
  function isObjectLike(value) {
    return !!value && typeof value == 'object';
  }

  /**
   * Checks if `value` is classified as a `Symbol` primitive or object.
   *
   * @static
   * @memberOf _
   * @since 4.0.0
   * @category Lang
   * @param {*} value The value to check.
   * @returns {boolean} Returns `true` if `value` is a symbol, else `false`.
   * @example
   *
   * _.isSymbol(Symbol.iterator);
   * // => true
   *
   * _.isSymbol('abc');
   * // => false
   */
  function isSymbol(value) {
    return typeof value == 'symbol' ||
      (isObjectLike(value) && objectToString.call(value) == symbolTag);
  }

  /**
   * Converts `value` to a number.
   *
   * @static
   * @memberOf _
   * @since 4.0.0
   * @category Lang
   * @param {*} value The value to process.
   * @returns {number} Returns the number.
   * @example
   *
   * _.toNumber(3.2);
   * // => 3.2
   *
   * _.toNumber(Number.MIN_VALUE);
   * // => 5e-324
   *
   * _.toNumber(Infinity);
   * // => Infinity
   *
   * _.toNumber('3.2');
   * // => 3.2
   */
  function toNumber(value) {
    if (typeof value == 'number') {
      return value;
    }
    if (isSymbol(value)) {
      return NAN;
    }
    if (isObject(value)) {
      var other = typeof value.valueOf == 'function' ? value.valueOf() : value;
      value = isObject(other) ? (other + '') : other;
    }
    if (typeof value != 'string') {
      return value === 0 ? value : +value;
    }
    value = value.replace(reTrim, '');
    var isBinary = reIsBinary.test(value);
    return (isBinary || reIsOctal.test(value))
      ? freeParseInt(value.slice(2), isBinary ? 2 : 8)
      : (reIsBadHex.test(value) ? NAN : +value);
  }

  module.exports = throttle;

  }).call(this)}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
  },{}],47:[function(require,module,exports){
  'use strict';
  module.exports = Math.log2 || function (x) {
    return Math.log(x) * Math.LOG2E;
  };

  },{}],48:[function(require,module,exports){
  var wildcard = require('wildcard');
  var reMimePartSplit = /[\/\+\.]/;

  /**
    # mime-match

    A simple function to checker whether a target mime type matches a mime-type
    pattern (e.g. image/jpeg matches image/jpeg OR image/*).

    ## Example Usage

    <<< example.js

  **/
  module.exports = function(target, pattern) {
    function test(pattern) {
      var result = wildcard(pattern, target, reMimePartSplit);

      // ensure that we have a valid mime type (should have two parts)
      return result && result.length >= 2;
    }

    return pattern ? test(pattern.split(';')[0]) : test;
  };

  },{"wildcard":55}],49:[function(require,module,exports){
  /**
  * Create an event emitter with namespaces
  * @name createNamespaceEmitter
  * @example
  * var emitter = require('./index')()
  *
  * emitter.on('*', function () {
  *   console.log('all events emitted', this.event)
  * })
  *
  * emitter.on('example', function () {
  *   console.log('example event emitted')
  * })
  */
  module.exports = function createNamespaceEmitter () {
    var emitter = {}
    var _fns = emitter._fns = {}

    /**
    * Emit an event. Optionally namespace the event. Handlers are fired in the order in which they were added with exact matches taking precedence. Separate the namespace and event with a `:`
    * @name emit
    * @param {String} event – the name of the event, with optional namespace
    * @param {...*} data – up to 6 arguments that are passed to the event listener
    * @example
    * emitter.emit('example')
    * emitter.emit('demo:test')
    * emitter.emit('data', { example: true}, 'a string', 1)
    */
    emitter.emit = function emit (event, arg1, arg2, arg3, arg4, arg5, arg6) {
      var toEmit = getListeners(event)

      if (toEmit.length) {
        emitAll(event, toEmit, [arg1, arg2, arg3, arg4, arg5, arg6])
      }
    }

    /**
    * Create en event listener.
    * @name on
    * @param {String} event
    * @param {Function} fn
    * @example
    * emitter.on('example', function () {})
    * emitter.on('demo', function () {})
    */
    emitter.on = function on (event, fn) {
      if (!_fns[event]) {
        _fns[event] = []
      }

      _fns[event].push(fn)
    }

    /**
    * Create en event listener that fires once.
    * @name once
    * @param {String} event
    * @param {Function} fn
    * @example
    * emitter.once('example', function () {})
    * emitter.once('demo', function () {})
    */
    emitter.once = function once (event, fn) {
      function one () {
        fn.apply(this, arguments)
        emitter.off(event, one)
      }
      this.on(event, one)
    }

    /**
    * Stop listening to an event. Stop all listeners on an event by only passing the event name. Stop a single listener by passing that event handler as a callback.
    * You must be explicit about what will be unsubscribed: `emitter.off('demo')` will unsubscribe an `emitter.on('demo')` listener,
    * `emitter.off('demo:example')` will unsubscribe an `emitter.on('demo:example')` listener
    * @name off
    * @param {String} event
    * @param {Function} [fn] – the specific handler
    * @example
    * emitter.off('example')
    * emitter.off('demo', function () {})
    */
    emitter.off = function off (event, fn) {
      var keep = []

      if (event && fn) {
        var fns = this._fns[event]
        var i = 0
        var l = fns ? fns.length : 0

        for (i; i < l; i++) {
          if (fns[i] !== fn) {
            keep.push(fns[i])
          }
        }
      }

      keep.length ? this._fns[event] = keep : delete this._fns[event]
    }

    function getListeners (e) {
      var out = _fns[e] ? _fns[e] : []
      var idx = e.indexOf(':')
      var args = (idx === -1) ? [e] : [e.substring(0, idx), e.substring(idx + 1)]

      var keys = Object.keys(_fns)
      var i = 0
      var l = keys.length

      for (i; i < l; i++) {
        var key = keys[i]
        if (key === '*') {
          out = out.concat(_fns[key])
        }

        if (args.length === 2 && args[0] === key) {
          out = out.concat(_fns[key])
          break
        }
      }

      return out
    }

    function emitAll (e, fns, args) {
      var i = 0
      var l = fns.length

      for (i; i < l; i++) {
        if (!fns[i]) break
        fns[i].event = e
        fns[i].apply(fns[i], args)
      }
    }

    return emitter
  }

  },{}],50:[function(require,module,exports){
  !function() {
      'use strict';
      function VNode() {}
      function h(nodeName, attributes) {
          var lastSimple, child, simple, i, children = EMPTY_CHILDREN;
          for (i = arguments.length; i-- > 2; ) stack.push(arguments[i]);
          if (attributes && null != attributes.children) {
              if (!stack.length) stack.push(attributes.children);
              delete attributes.children;
          }
          while (stack.length) if ((child = stack.pop()) && void 0 !== child.pop) for (i = child.length; i--; ) stack.push(child[i]); else {
              if ('boolean' == typeof child) child = null;
              if (simple = 'function' != typeof nodeName) if (null == child) child = ''; else if ('number' == typeof child) child = String(child); else if ('string' != typeof child) simple = !1;
              if (simple && lastSimple) children[children.length - 1] += child; else if (children === EMPTY_CHILDREN) children = [ child ]; else children.push(child);
              lastSimple = simple;
          }
          var p = new VNode();
          p.nodeName = nodeName;
          p.children = children;
          p.attributes = null == attributes ? void 0 : attributes;
          p.key = null == attributes ? void 0 : attributes.key;
          if (void 0 !== options.vnode) options.vnode(p);
          return p;
      }
      function extend(obj, props) {
          for (var i in props) obj[i] = props[i];
          return obj;
      }
      function cloneElement(vnode, props) {
          return h(vnode.nodeName, extend(extend({}, vnode.attributes), props), arguments.length > 2 ? [].slice.call(arguments, 2) : vnode.children);
      }
      function enqueueRender(component) {
          if (!component.__d && (component.__d = !0) && 1 == items.push(component)) (options.debounceRendering || defer)(rerender);
      }
      function rerender() {
          var p, list = items;
          items = [];
          while (p = list.pop()) if (p.__d) renderComponent(p);
      }
      function isSameNodeType(node, vnode, hydrating) {
          if ('string' == typeof vnode || 'number' == typeof vnode) return void 0 !== node.splitText;
          if ('string' == typeof vnode.nodeName) return !node._componentConstructor && isNamedNode(node, vnode.nodeName); else return hydrating || node._componentConstructor === vnode.nodeName;
      }
      function isNamedNode(node, nodeName) {
          return node.__n === nodeName || node.nodeName.toLowerCase() === nodeName.toLowerCase();
      }
      function getNodeProps(vnode) {
          var props = extend({}, vnode.attributes);
          props.children = vnode.children;
          var defaultProps = vnode.nodeName.defaultProps;
          if (void 0 !== defaultProps) for (var i in defaultProps) if (void 0 === props[i]) props[i] = defaultProps[i];
          return props;
      }
      function createNode(nodeName, isSvg) {
          var node = isSvg ? document.createElementNS('http://www.w3.org/2000/svg', nodeName) : document.createElement(nodeName);
          node.__n = nodeName;
          return node;
      }
      function removeNode(node) {
          var parentNode = node.parentNode;
          if (parentNode) parentNode.removeChild(node);
      }
      function setAccessor(node, name, old, value, isSvg) {
          if ('className' === name) name = 'class';
          if ('key' === name) ; else if ('ref' === name) {
              if (old) old(null);
              if (value) value(node);
          } else if ('class' === name && !isSvg) node.className = value || ''; else if ('style' === name) {
              if (!value || 'string' == typeof value || 'string' == typeof old) node.style.cssText = value || '';
              if (value && 'object' == typeof value) {
                  if ('string' != typeof old) for (var i in old) if (!(i in value)) node.style[i] = '';
                  for (var i in value) node.style[i] = 'number' == typeof value[i] && !1 === IS_NON_DIMENSIONAL.test(i) ? value[i] + 'px' : value[i];
              }
          } else if ('dangerouslySetInnerHTML' === name) {
              if (value) node.innerHTML = value.__html || '';
          } else if ('o' == name[0] && 'n' == name[1]) {
              var useCapture = name !== (name = name.replace(/Capture$/, ''));
              name = name.toLowerCase().substring(2);
              if (value) {
                  if (!old) node.addEventListener(name, eventProxy, useCapture);
              } else node.removeEventListener(name, eventProxy, useCapture);
              (node.__l || (node.__l = {}))[name] = value;
          } else if ('list' !== name && 'type' !== name && !isSvg && name in node) {
              setProperty(node, name, null == value ? '' : value);
              if (null == value || !1 === value) node.removeAttribute(name);
          } else {
              var ns = isSvg && name !== (name = name.replace(/^xlink:?/, ''));
              if (null == value || !1 === value) if (ns) node.removeAttributeNS('http://www.w3.org/1999/xlink', name.toLowerCase()); else node.removeAttribute(name); else if ('function' != typeof value) if (ns) node.setAttributeNS('http://www.w3.org/1999/xlink', name.toLowerCase(), value); else node.setAttribute(name, value);
          }
      }
      function setProperty(node, name, value) {
          try {
              node[name] = value;
          } catch (e) {}
      }
      function eventProxy(e) {
          return this.__l[e.type](options.event && options.event(e) || e);
      }
      function flushMounts() {
          var c;
          while (c = mounts.pop()) {
              if (options.afterMount) options.afterMount(c);
              if (c.componentDidMount) c.componentDidMount();
          }
      }
      function diff(dom, vnode, context, mountAll, parent, componentRoot) {
          if (!diffLevel++) {
              isSvgMode = null != parent && void 0 !== parent.ownerSVGElement;
              hydrating = null != dom && !('__preactattr_' in dom);
          }
          var ret = idiff(dom, vnode, context, mountAll, componentRoot);
          if (parent && ret.parentNode !== parent) parent.appendChild(ret);
          if (!--diffLevel) {
              hydrating = !1;
              if (!componentRoot) flushMounts();
          }
          return ret;
      }
      function idiff(dom, vnode, context, mountAll, componentRoot) {
          var out = dom, prevSvgMode = isSvgMode;
          if (null == vnode || 'boolean' == typeof vnode) vnode = '';
          if ('string' == typeof vnode || 'number' == typeof vnode) {
              if (dom && void 0 !== dom.splitText && dom.parentNode && (!dom._component || componentRoot)) {
                  if (dom.nodeValue != vnode) dom.nodeValue = vnode;
              } else {
                  out = document.createTextNode(vnode);
                  if (dom) {
                      if (dom.parentNode) dom.parentNode.replaceChild(out, dom);
                      recollectNodeTree(dom, !0);
                  }
              }
              out.__preactattr_ = !0;
              return out;
          }
          var vnodeName = vnode.nodeName;
          if ('function' == typeof vnodeName) return buildComponentFromVNode(dom, vnode, context, mountAll);
          isSvgMode = 'svg' === vnodeName ? !0 : 'foreignObject' === vnodeName ? !1 : isSvgMode;
          vnodeName = String(vnodeName);
          if (!dom || !isNamedNode(dom, vnodeName)) {
              out = createNode(vnodeName, isSvgMode);
              if (dom) {
                  while (dom.firstChild) out.appendChild(dom.firstChild);
                  if (dom.parentNode) dom.parentNode.replaceChild(out, dom);
                  recollectNodeTree(dom, !0);
              }
          }
          var fc = out.firstChild, props = out.__preactattr_, vchildren = vnode.children;
          if (null == props) {
              props = out.__preactattr_ = {};
              for (var a = out.attributes, i = a.length; i--; ) props[a[i].name] = a[i].value;
          }
          if (!hydrating && vchildren && 1 === vchildren.length && 'string' == typeof vchildren[0] && null != fc && void 0 !== fc.splitText && null == fc.nextSibling) {
              if (fc.nodeValue != vchildren[0]) fc.nodeValue = vchildren[0];
          } else if (vchildren && vchildren.length || null != fc) innerDiffNode(out, vchildren, context, mountAll, hydrating || null != props.dangerouslySetInnerHTML);
          diffAttributes(out, vnode.attributes, props);
          isSvgMode = prevSvgMode;
          return out;
      }
      function innerDiffNode(dom, vchildren, context, mountAll, isHydrating) {
          var j, c, f, vchild, child, originalChildren = dom.childNodes, children = [], keyed = {}, keyedLen = 0, min = 0, len = originalChildren.length, childrenLen = 0, vlen = vchildren ? vchildren.length : 0;
          if (0 !== len) for (var i = 0; i < len; i++) {
              var _child = originalChildren[i], props = _child.__preactattr_, key = vlen && props ? _child._component ? _child._component.__k : props.key : null;
              if (null != key) {
                  keyedLen++;
                  keyed[key] = _child;
              } else if (props || (void 0 !== _child.splitText ? isHydrating ? _child.nodeValue.trim() : !0 : isHydrating)) children[childrenLen++] = _child;
          }
          if (0 !== vlen) for (var i = 0; i < vlen; i++) {
              vchild = vchildren[i];
              child = null;
              var key = vchild.key;
              if (null != key) {
                  if (keyedLen && void 0 !== keyed[key]) {
                      child = keyed[key];
                      keyed[key] = void 0;
                      keyedLen--;
                  }
              } else if (!child && min < childrenLen) for (j = min; j < childrenLen; j++) if (void 0 !== children[j] && isSameNodeType(c = children[j], vchild, isHydrating)) {
                  child = c;
                  children[j] = void 0;
                  if (j === childrenLen - 1) childrenLen--;
                  if (j === min) min++;
                  break;
              }
              child = idiff(child, vchild, context, mountAll);
              f = originalChildren[i];
              if (child && child !== dom && child !== f) if (null == f) dom.appendChild(child); else if (child === f.nextSibling) removeNode(f); else dom.insertBefore(child, f);
          }
          if (keyedLen) for (var i in keyed) if (void 0 !== keyed[i]) recollectNodeTree(keyed[i], !1);
          while (min <= childrenLen) if (void 0 !== (child = children[childrenLen--])) recollectNodeTree(child, !1);
      }
      function recollectNodeTree(node, unmountOnly) {
          var component = node._component;
          if (component) unmountComponent(component); else {
              if (null != node.__preactattr_ && node.__preactattr_.ref) node.__preactattr_.ref(null);
              if (!1 === unmountOnly || null == node.__preactattr_) removeNode(node);
              removeChildren(node);
          }
      }
      function removeChildren(node) {
          node = node.lastChild;
          while (node) {
              var next = node.previousSibling;
              recollectNodeTree(node, !0);
              node = next;
          }
      }
      function diffAttributes(dom, attrs, old) {
          var name;
          for (name in old) if ((!attrs || null == attrs[name]) && null != old[name]) setAccessor(dom, name, old[name], old[name] = void 0, isSvgMode);
          for (name in attrs) if (!('children' === name || 'innerHTML' === name || name in old && attrs[name] === ('value' === name || 'checked' === name ? dom[name] : old[name]))) setAccessor(dom, name, old[name], old[name] = attrs[name], isSvgMode);
      }
      function collectComponent(component) {
          var name = component.constructor.name;
          (components[name] || (components[name] = [])).push(component);
      }
      function createComponent(Ctor, props, context) {
          var inst, list = components[Ctor.name];
          if (Ctor.prototype && Ctor.prototype.render) {
              inst = new Ctor(props, context);
              Component.call(inst, props, context);
          } else {
              inst = new Component(props, context);
              inst.constructor = Ctor;
              inst.render = doRender;
          }
          if (list) for (var i = list.length; i--; ) if (list[i].constructor === Ctor) {
              inst.__b = list[i].__b;
              list.splice(i, 1);
              break;
          }
          return inst;
      }
      function doRender(props, state, context) {
          return this.constructor(props, context);
      }
      function setComponentProps(component, props, opts, context, mountAll) {
          if (!component.__x) {
              component.__x = !0;
              if (component.__r = props.ref) delete props.ref;
              if (component.__k = props.key) delete props.key;
              if (!component.base || mountAll) {
                  if (component.componentWillMount) component.componentWillMount();
              } else if (component.componentWillReceiveProps) component.componentWillReceiveProps(props, context);
              if (context && context !== component.context) {
                  if (!component.__c) component.__c = component.context;
                  component.context = context;
              }
              if (!component.__p) component.__p = component.props;
              component.props = props;
              component.__x = !1;
              if (0 !== opts) if (1 === opts || !1 !== options.syncComponentUpdates || !component.base) renderComponent(component, 1, mountAll); else enqueueRender(component);
              if (component.__r) component.__r(component);
          }
      }
      function renderComponent(component, opts, mountAll, isChild) {
          if (!component.__x) {
              var rendered, inst, cbase, props = component.props, state = component.state, context = component.context, previousProps = component.__p || props, previousState = component.__s || state, previousContext = component.__c || context, isUpdate = component.base, nextBase = component.__b, initialBase = isUpdate || nextBase, initialChildComponent = component._component, skip = !1;
              if (isUpdate) {
                  component.props = previousProps;
                  component.state = previousState;
                  component.context = previousContext;
                  if (2 !== opts && component.shouldComponentUpdate && !1 === component.shouldComponentUpdate(props, state, context)) skip = !0; else if (component.componentWillUpdate) component.componentWillUpdate(props, state, context);
                  component.props = props;
                  component.state = state;
                  component.context = context;
              }
              component.__p = component.__s = component.__c = component.__b = null;
              component.__d = !1;
              if (!skip) {
                  rendered = component.render(props, state, context);
                  if (component.getChildContext) context = extend(extend({}, context), component.getChildContext());
                  var toUnmount, base, childComponent = rendered && rendered.nodeName;
                  if ('function' == typeof childComponent) {
                      var childProps = getNodeProps(rendered);
                      inst = initialChildComponent;
                      if (inst && inst.constructor === childComponent && childProps.key == inst.__k) setComponentProps(inst, childProps, 1, context, !1); else {
                          toUnmount = inst;
                          component._component = inst = createComponent(childComponent, childProps, context);
                          inst.__b = inst.__b || nextBase;
                          inst.__u = component;
                          setComponentProps(inst, childProps, 0, context, !1);
                          renderComponent(inst, 1, mountAll, !0);
                      }
                      base = inst.base;
                  } else {
                      cbase = initialBase;
                      toUnmount = initialChildComponent;
                      if (toUnmount) cbase = component._component = null;
                      if (initialBase || 1 === opts) {
                          if (cbase) cbase._component = null;
                          base = diff(cbase, rendered, context, mountAll || !isUpdate, initialBase && initialBase.parentNode, !0);
                      }
                  }
                  if (initialBase && base !== initialBase && inst !== initialChildComponent) {
                      var baseParent = initialBase.parentNode;
                      if (baseParent && base !== baseParent) {
                          baseParent.replaceChild(base, initialBase);
                          if (!toUnmount) {
                              initialBase._component = null;
                              recollectNodeTree(initialBase, !1);
                          }
                      }
                  }
                  if (toUnmount) unmountComponent(toUnmount);
                  component.base = base;
                  if (base && !isChild) {
                      var componentRef = component, t = component;
                      while (t = t.__u) (componentRef = t).base = base;
                      base._component = componentRef;
                      base._componentConstructor = componentRef.constructor;
                  }
              }
              if (!isUpdate || mountAll) mounts.unshift(component); else if (!skip) {
                  if (component.componentDidUpdate) component.componentDidUpdate(previousProps, previousState, previousContext);
                  if (options.afterUpdate) options.afterUpdate(component);
              }
              if (null != component.__h) while (component.__h.length) component.__h.pop().call(component);
              if (!diffLevel && !isChild) flushMounts();
          }
      }
      function buildComponentFromVNode(dom, vnode, context, mountAll) {
          var c = dom && dom._component, originalComponent = c, oldDom = dom, isDirectOwner = c && dom._componentConstructor === vnode.nodeName, isOwner = isDirectOwner, props = getNodeProps(vnode);
          while (c && !isOwner && (c = c.__u)) isOwner = c.constructor === vnode.nodeName;
          if (c && isOwner && (!mountAll || c._component)) {
              setComponentProps(c, props, 3, context, mountAll);
              dom = c.base;
          } else {
              if (originalComponent && !isDirectOwner) {
                  unmountComponent(originalComponent);
                  dom = oldDom = null;
              }
              c = createComponent(vnode.nodeName, props, context);
              if (dom && !c.__b) {
                  c.__b = dom;
                  oldDom = null;
              }
              setComponentProps(c, props, 1, context, mountAll);
              dom = c.base;
              if (oldDom && dom !== oldDom) {
                  oldDom._component = null;
                  recollectNodeTree(oldDom, !1);
              }
          }
          return dom;
      }
      function unmountComponent(component) {
          if (options.beforeUnmount) options.beforeUnmount(component);
          var base = component.base;
          component.__x = !0;
          if (component.componentWillUnmount) component.componentWillUnmount();
          component.base = null;
          var inner = component._component;
          if (inner) unmountComponent(inner); else if (base) {
              if (base.__preactattr_ && base.__preactattr_.ref) base.__preactattr_.ref(null);
              component.__b = base;
              removeNode(base);
              collectComponent(component);
              removeChildren(base);
          }
          if (component.__r) component.__r(null);
      }
      function Component(props, context) {
          this.__d = !0;
          this.context = context;
          this.props = props;
          this.state = this.state || {};
      }
      function render(vnode, parent, merge) {
          return diff(merge, vnode, {}, !1, parent, !1);
      }
      var options = {};
      var stack = [];
      var EMPTY_CHILDREN = [];
      var defer = 'function' == typeof Promise ? Promise.resolve().then.bind(Promise.resolve()) : setTimeout;
      var IS_NON_DIMENSIONAL = /acit|ex(?:s|g|n|p|$)|rph|ows|mnc|ntw|ine[ch]|zoo|^ord/i;
      var items = [];
      var mounts = [];
      var diffLevel = 0;
      var isSvgMode = !1;
      var hydrating = !1;
      var components = {};
      extend(Component.prototype, {
          setState: function(state, callback) {
              var s = this.state;
              if (!this.__s) this.__s = extend({}, s);
              extend(s, 'function' == typeof state ? state(s, this.props) : state);
              if (callback) (this.__h = this.__h || []).push(callback);
              enqueueRender(this);
          },
          forceUpdate: function(callback) {
              if (callback) (this.__h = this.__h || []).push(callback);
              renderComponent(this, 2);
          },
          render: function() {}
      });
      var preact = {
          h: h,
          createElement: h,
          cloneElement: cloneElement,
          Component: Component,
          render: render,
          rerender: rerender,
          options: options
      };
      if ('undefined' != typeof module) module.exports = preact; else self.preact = preact;
  }();

  },{}],51:[function(require,module,exports){
  var has = Object.prototype.hasOwnProperty

  /**
   * Stringify an object for use in a query string.
   *
   * @param {Object} obj - The object.
   * @param {string} prefix - When nesting, the parent key.
   *     keys in `obj` will be stringified as `prefix[key]`.
   * @returns {string}
   */

  module.exports = function queryStringify (obj, prefix) {
    var pairs = []
    for (var key in obj) {
      if (!has.call(obj, key)) {
        continue
      }

      var value = obj[key]
      var enkey = encodeURIComponent(key)
      var pair
      if (typeof value === 'object') {
        pair = queryStringify(value, prefix ? prefix + '[' + enkey + ']' : enkey)
      } else {
        pair = (prefix ? prefix + '[' + enkey + ']' : enkey) + '=' + encodeURIComponent(value)
      }
      pairs.push(pair)
    }
    return pairs.join('&')
  }

  },{}],52:[function(require,module,exports){
  'use strict';

  var has = Object.prototype.hasOwnProperty
    , undef;

  /**
   * Decode a URI encoded string.
   *
   * @param {String} input The URI encoded string.
   * @returns {String|Null} The decoded string.
   * @api private
   */
  function decode(input) {
    try {
      return decodeURIComponent(input.replace(/\+/g, ' '));
    } catch (e) {
      return null;
    }
  }

  /**
   * Attempts to encode a given input.
   *
   * @param {String} input The string that needs to be encoded.
   * @returns {String|Null} The encoded string.
   * @api private
   */
  function encode(input) {
    try {
      return encodeURIComponent(input);
    } catch (e) {
      return null;
    }
  }

  /**
   * Simple query string parser.
   *
   * @param {String} query The query string that needs to be parsed.
   * @returns {Object}
   * @api public
   */
  function querystring(query) {
    var parser = /([^=?#&]+)=?([^&]*)/g
      , result = {}
      , part;

    while (part = parser.exec(query)) {
      var key = decode(part[1])
        , value = decode(part[2]);

      //
      // Prevent overriding of existing properties. This ensures that build-in
      // methods like `toString` or __proto__ are not overriden by malicious
      // querystrings.
      //
      // In the case if failed decoding, we want to omit the key/value pairs
      // from the result.
      //
      if (key === null || value === null || key in result) continue;
      result[key] = value;
    }

    return result;
  }

  /**
   * Transform a query string to an object.
   *
   * @param {Object} obj Object that should be transformed.
   * @param {String} prefix Optional prefix.
   * @returns {String}
   * @api public
   */
  function querystringify(obj, prefix) {
    prefix = prefix || '';

    var pairs = []
      , value
      , key;

    //
    // Optionally prefix with a '?' if needed
    //
    if ('string' !== typeof prefix) prefix = '?';

    for (key in obj) {
      if (has.call(obj, key)) {
        value = obj[key];

        //
        // Edge cases where we actually want to encode the value to an empty
        // string instead of the stringified value.
        //
        if (!value && (value === null || value === undef || isNaN(value))) {
          value = '';
        }

        key = encode(key);
        value = encode(value);

        //
        // If we failed to encode the strings, we should bail out as we don't
        // want to add invalid strings to the query.
        //
        if (key === null || value === null) continue;
        pairs.push(key +'='+ value);
      }
    }

    return pairs.length ? prefix + pairs.join('&') : '';
  }

  //
  // Expose the module.
  //
  exports.stringify = querystringify;
  exports.parse = querystring;

  },{}],53:[function(require,module,exports){
  'use strict';

  /**
   * Check if we're required to add a port number.
   *
   * @see https://url.spec.whatwg.org/#default-port
   * @param {Number|String} port Port number we need to check
   * @param {String} protocol Protocol we need to check against.
   * @returns {Boolean} Is it a default port for the given protocol
   * @api private
   */
  module.exports = function required(port, protocol) {
    protocol = protocol.split(':')[0];
    port = +port;

    if (!port) return false;

    switch (protocol) {
      case 'http':
      case 'ws':
      return port !== 80;

      case 'https':
      case 'wss':
      return port !== 443;

      case 'ftp':
      return port !== 21;

      case 'gopher':
      return port !== 70;

      case 'file':
      return false;
    }

    return port !== 0;
  };

  },{}],54:[function(require,module,exports){
  (function (global){(function (){
  'use strict';

  var required = require('requires-port')
    , qs = require('querystringify')
    , slashes = /^[A-Za-z][A-Za-z0-9+-.]*:[\\/]+/
    , protocolre = /^([a-z][a-z0-9.+-]*:)?([\\/]{1,})?([\S\s]*)/i
    , whitespace = '[\\x09\\x0A\\x0B\\x0C\\x0D\\x20\\xA0\\u1680\\u180E\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2007\\u2008\\u2009\\u200A\\u202F\\u205F\\u3000\\u2028\\u2029\\uFEFF]'
    , left = new RegExp('^'+ whitespace +'+');

  /**
   * Trim a given string.
   *
   * @param {String} str String to trim.
   * @public
   */
  function trimLeft(str) {
    return (str ? str : '').toString().replace(left, '');
  }

  /**
   * These are the parse rules for the URL parser, it informs the parser
   * about:
   *
   * 0. The char it Needs to parse, if it's a string it should be done using
   *    indexOf, RegExp using exec and NaN means set as current value.
   * 1. The property we should set when parsing this value.
   * 2. Indication if it's backwards or forward parsing, when set as number it's
   *    the value of extra chars that should be split off.
   * 3. Inherit from location if non existing in the parser.
   * 4. `toLowerCase` the resulting value.
   */
  var rules = [
    ['#', 'hash'],                        // Extract from the back.
    ['?', 'query'],                       // Extract from the back.
    function sanitize(address) {          // Sanitize what is left of the address
      return address.replace('\\', '/');
    },
    ['/', 'pathname'],                    // Extract from the back.
    ['@', 'auth', 1],                     // Extract from the front.
    [NaN, 'host', undefined, 1, 1],       // Set left over value.
    [/:(\d+)$/, 'port', undefined, 1],    // RegExp the back.
    [NaN, 'hostname', undefined, 1, 1]    // Set left over.
  ];

  /**
   * These properties should not be copied or inherited from. This is only needed
   * for all non blob URL's as a blob URL does not include a hash, only the
   * origin.
   *
   * @type {Object}
   * @private
   */
  var ignore = { hash: 1, query: 1 };

  /**
   * The location object differs when your code is loaded through a normal page,
   * Worker or through a worker using a blob. And with the blobble begins the
   * trouble as the location object will contain the URL of the blob, not the
   * location of the page where our code is loaded in. The actual origin is
   * encoded in the `pathname` so we can thankfully generate a good "default"
   * location from it so we can generate proper relative URL's again.
   *
   * @param {Object|String} loc Optional default location object.
   * @returns {Object} lolcation object.
   * @public
   */
  function lolcation(loc) {
    var globalVar;

    if (typeof window !== 'undefined') globalVar = window;
    else if (typeof global !== 'undefined') globalVar = global;
    else if (typeof self !== 'undefined') globalVar = self;
    else globalVar = {};

    var location = globalVar.location || {};
    loc = loc || location;

    var finaldestination = {}
      , type = typeof loc
      , key;

    if ('blob:' === loc.protocol) {
      finaldestination = new Url(unescape(loc.pathname), {});
    } else if ('string' === type) {
      finaldestination = new Url(loc, {});
      for (key in ignore) delete finaldestination[key];
    } else if ('object' === type) {
      for (key in loc) {
        if (key in ignore) continue;
        finaldestination[key] = loc[key];
      }

      if (finaldestination.slashes === undefined) {
        finaldestination.slashes = slashes.test(loc.href);
      }
    }

    return finaldestination;
  }

  /**
   * @typedef ProtocolExtract
   * @type Object
   * @property {String} protocol Protocol matched in the URL, in lowercase.
   * @property {Boolean} slashes `true` if protocol is followed by "//", else `false`.
   * @property {String} rest Rest of the URL that is not part of the protocol.
   */

  /**
   * Extract protocol information from a URL with/without double slash ("//").
   *
   * @param {String} address URL we want to extract from.
   * @return {ProtocolExtract} Extracted information.
   * @private
   */
  function extractProtocol(address) {
    address = trimLeft(address);

    var match = protocolre.exec(address)
      , protocol = match[1] ? match[1].toLowerCase() : ''
      , slashes = !!(match[2] && match[2].length >= 2)
      , rest =  match[2] && match[2].length === 1 ? '/' + match[3] : match[3];

    return {
      protocol: protocol,
      slashes: slashes,
      rest: rest
    };
  }

  /**
   * Resolve a relative URL pathname against a base URL pathname.
   *
   * @param {String} relative Pathname of the relative URL.
   * @param {String} base Pathname of the base URL.
   * @return {String} Resolved pathname.
   * @private
   */
  function resolve(relative, base) {
    if (relative === '') return base;

    var path = (base || '/').split('/').slice(0, -1).concat(relative.split('/'))
      , i = path.length
      , last = path[i - 1]
      , unshift = false
      , up = 0;

    while (i--) {
      if (path[i] === '.') {
        path.splice(i, 1);
      } else if (path[i] === '..') {
        path.splice(i, 1);
        up++;
      } else if (up) {
        if (i === 0) unshift = true;
        path.splice(i, 1);
        up--;
      }
    }

    if (unshift) path.unshift('');
    if (last === '.' || last === '..') path.push('');

    return path.join('/');
  }

  /**
   * The actual URL instance. Instead of returning an object we've opted-in to
   * create an actual constructor as it's much more memory efficient and
   * faster and it pleases my OCD.
   *
   * It is worth noting that we should not use `URL` as class name to prevent
   * clashes with the global URL instance that got introduced in browsers.
   *
   * @constructor
   * @param {String} address URL we want to parse.
   * @param {Object|String} [location] Location defaults for relative paths.
   * @param {Boolean|Function} [parser] Parser for the query string.
   * @private
   */
  function Url(address, location, parser) {
    address = trimLeft(address);

    if (!(this instanceof Url)) {
      return new Url(address, location, parser);
    }

    var relative, extracted, parse, instruction, index, key
      , instructions = rules.slice()
      , type = typeof location
      , url = this
      , i = 0;

    //
    // The following if statements allows this module two have compatibility with
    // 2 different API:
    //
    // 1. Node.js's `url.parse` api which accepts a URL, boolean as arguments
    //    where the boolean indicates that the query string should also be parsed.
    //
    // 2. The `URL` interface of the browser which accepts a URL, object as
    //    arguments. The supplied object will be used as default values / fall-back
    //    for relative paths.
    //
    if ('object' !== type && 'string' !== type) {
      parser = location;
      location = null;
    }

    if (parser && 'function' !== typeof parser) parser = qs.parse;

    location = lolcation(location);

    //
    // Extract protocol information before running the instructions.
    //
    extracted = extractProtocol(address || '');
    relative = !extracted.protocol && !extracted.slashes;
    url.slashes = extracted.slashes || relative && location.slashes;
    url.protocol = extracted.protocol || location.protocol || '';
    address = extracted.rest;

    //
    // When the authority component is absent the URL starts with a path
    // component.
    //
    if (!extracted.slashes) instructions[3] = [/(.*)/, 'pathname'];

    for (; i < instructions.length; i++) {
      instruction = instructions[i];

      if (typeof instruction === 'function') {
        address = instruction(address);
        continue;
      }

      parse = instruction[0];
      key = instruction[1];

      if (parse !== parse) {
        url[key] = address;
      } else if ('string' === typeof parse) {
        if (~(index = address.indexOf(parse))) {
          if ('number' === typeof instruction[2]) {
            url[key] = address.slice(0, index);
            address = address.slice(index + instruction[2]);
          } else {
            url[key] = address.slice(index);
            address = address.slice(0, index);
          }
        }
      } else if ((index = parse.exec(address))) {
        url[key] = index[1];
        address = address.slice(0, index.index);
      }

      url[key] = url[key] || (
        relative && instruction[3] ? location[key] || '' : ''
      );

      //
      // Hostname, host and protocol should be lowercased so they can be used to
      // create a proper `origin`.
      //
      if (instruction[4]) url[key] = url[key].toLowerCase();
    }

    //
    // Also parse the supplied query string in to an object. If we're supplied
    // with a custom parser as function use that instead of the default build-in
    // parser.
    //
    if (parser) url.query = parser(url.query);

    //
    // If the URL is relative, resolve the pathname against the base URL.
    //
    if (
        relative
      && location.slashes
      && url.pathname.charAt(0) !== '/'
      && (url.pathname !== '' || location.pathname !== '')
    ) {
      url.pathname = resolve(url.pathname, location.pathname);
    }

    //
    // Default to a / for pathname if none exists. This normalizes the URL
    // to always have a /
    //
    if (url.pathname.charAt(0) !== '/' && url.hostname) {
      url.pathname = '/' + url.pathname;
    }

    //
    // We should not add port numbers if they are already the default port number
    // for a given protocol. As the host also contains the port number we're going
    // override it with the hostname which contains no port number.
    //
    if (!required(url.port, url.protocol)) {
      url.host = url.hostname;
      url.port = '';
    }

    //
    // Parse down the `auth` for the username and password.
    //
    url.username = url.password = '';
    if (url.auth) {
      instruction = url.auth.split(':');
      url.username = instruction[0] || '';
      url.password = instruction[1] || '';
    }

    url.origin = url.protocol && url.host && url.protocol !== 'file:'
      ? url.protocol +'//'+ url.host
      : 'null';

    //
    // The href is just the compiled result.
    //
    url.href = url.toString();
  }

  /**
   * This is convenience method for changing properties in the URL instance to
   * insure that they all propagate correctly.
   *
   * @param {String} part          Property we need to adjust.
   * @param {Mixed} value          The newly assigned value.
   * @param {Boolean|Function} fn  When setting the query, it will be the function
   *                               used to parse the query.
   *                               When setting the protocol, double slash will be
   *                               removed from the final url if it is true.
   * @returns {URL} URL instance for chaining.
   * @public
   */
  function set(part, value, fn) {
    var url = this;

    switch (part) {
      case 'query':
        if ('string' === typeof value && value.length) {
          value = (fn || qs.parse)(value);
        }

        url[part] = value;
        break;

      case 'port':
        url[part] = value;

        if (!required(value, url.protocol)) {
          url.host = url.hostname;
          url[part] = '';
        } else if (value) {
          url.host = url.hostname +':'+ value;
        }

        break;

      case 'hostname':
        url[part] = value;

        if (url.port) value += ':'+ url.port;
        url.host = value;
        break;

      case 'host':
        url[part] = value;

        if (/:\d+$/.test(value)) {
          value = value.split(':');
          url.port = value.pop();
          url.hostname = value.join(':');
        } else {
          url.hostname = value;
          url.port = '';
        }

        break;

      case 'protocol':
        url.protocol = value.toLowerCase();
        url.slashes = !fn;
        break;

      case 'pathname':
      case 'hash':
        if (value) {
          var char = part === 'pathname' ? '/' : '#';
          url[part] = value.charAt(0) !== char ? char + value : value;
        } else {
          url[part] = value;
        }
        break;

      default:
        url[part] = value;
    }

    for (var i = 0; i < rules.length; i++) {
      var ins = rules[i];

      if (ins[4]) url[ins[1]] = url[ins[1]].toLowerCase();
    }

    url.origin = url.protocol && url.host && url.protocol !== 'file:'
      ? url.protocol +'//'+ url.host
      : 'null';

    url.href = url.toString();

    return url;
  }

  /**
   * Transform the properties back in to a valid and full URL string.
   *
   * @param {Function} stringify Optional query stringify function.
   * @returns {String} Compiled version of the URL.
   * @public
   */
  function toString(stringify) {
    if (!stringify || 'function' !== typeof stringify) stringify = qs.stringify;

    var query
      , url = this
      , protocol = url.protocol;

    if (protocol && protocol.charAt(protocol.length - 1) !== ':') protocol += ':';

    var result = protocol + (url.slashes ? '//' : '');

    if (url.username) {
      result += url.username;
      if (url.password) result += ':'+ url.password;
      result += '@';
    }

    result += url.host + url.pathname;

    query = 'object' === typeof url.query ? stringify(url.query) : url.query;
    if (query) result += '?' !== query.charAt(0) ? '?'+ query : query;

    if (url.hash) result += url.hash;

    return result;
  }

  Url.prototype = { set: set, toString: toString };

  //
  // Expose the URL parser and some additional properties that might be useful for
  // others or testing.
  //
  Url.extractProtocol = extractProtocol;
  Url.location = lolcation;
  Url.trimLeft = trimLeft;
  Url.qs = qs;

  module.exports = Url;

  }).call(this)}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
  },{"querystringify":52,"requires-port":53}],55:[function(require,module,exports){
  /* jshint node: true */
  'use strict';

  /**
    # wildcard

    Very simple wildcard matching, which is designed to provide the same
    functionality that is found in the
    [eve](https://github.com/adobe-webplatform/eve) eventing library.

    ## Usage

    It works with strings:

    <<< examples/strings.js

    Arrays:

    <<< examples/arrays.js

    Objects (matching against keys):

    <<< examples/objects.js

    While the library works in Node, if you are are looking for file-based
    wildcard matching then you should have a look at:

    <https://github.com/isaacs/node-glob>
  **/

  function WildcardMatcher(text, separator) {
    this.text = text = text || '';
    this.hasWild = ~text.indexOf('*');
    this.separator = separator;
    this.parts = text.split(separator);
  }

  WildcardMatcher.prototype.match = function(input) {
    var matches = true;
    var parts = this.parts;
    var ii;
    var partsCount = parts.length;
    var testParts;

    if (typeof input == 'string' || input instanceof String) {
      if (!this.hasWild && this.text != input) {
        matches = false;
      } else {
        testParts = (input || '').split(this.separator);
        for (ii = 0; matches && ii < partsCount; ii++) {
          if (parts[ii] === '*')  {
            continue;
          } else if (ii < testParts.length) {
            matches = parts[ii] === testParts[ii];
          } else {
            matches = false;
          }
        }

        // If matches, then return the component parts
        matches = matches && testParts;
      }
    }
    else if (typeof input.splice == 'function') {
      matches = [];

      for (ii = input.length; ii--; ) {
        if (this.match(input[ii])) {
          matches[matches.length] = input[ii];
        }
      }
    }
    else if (typeof input == 'object') {
      matches = {};

      for (var key in input) {
        if (this.match(key)) {
          matches[key] = input[key];
        }
      }
    }

    return matches;
  };

  module.exports = function(text, test, separator) {
    var matcher = new WildcardMatcher(text, separator || /[\/\.]/);
    if (typeof test != 'undefined') {
      return matcher.match(test);
    }

    return matcher;
  };

  },{}],56:[function(require,module,exports){
  'use strict'

  exports.byteLength = byteLength
  exports.toByteArray = toByteArray
  exports.fromByteArray = fromByteArray

  var lookup = []
  var revLookup = []
  var Arr = typeof Uint8Array !== 'undefined' ? Uint8Array : Array

  var code = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  for (var i = 0, len = code.length; i < len; ++i) {
    lookup[i] = code[i]
    revLookup[code.charCodeAt(i)] = i
  }

  // Support decoding URL-safe base64 strings, as Node.js does.
  // See: https://en.wikipedia.org/wiki/Base64#URL_applications
  revLookup['-'.charCodeAt(0)] = 62
  revLookup['_'.charCodeAt(0)] = 63

  function getLens (b64) {
    var len = b64.length

    if (len % 4 > 0) {
      throw new Error('Invalid string. Length must be a multiple of 4')
    }

    // Trim off extra bytes after placeholder bytes are found
    // See: https://github.com/beatgammit/base64-js/issues/42
    var validLen = b64.indexOf('=')
    if (validLen === -1) validLen = len

    var placeHoldersLen = validLen === len
      ? 0
      : 4 - (validLen % 4)

    return [validLen, placeHoldersLen]
  }

  // base64 is 4/3 + up to two characters of the original data
  function byteLength (b64) {
    var lens = getLens(b64)
    var validLen = lens[0]
    var placeHoldersLen = lens[1]
    return ((validLen + placeHoldersLen) * 3 / 4) - placeHoldersLen
  }

  function _byteLength (b64, validLen, placeHoldersLen) {
    return ((validLen + placeHoldersLen) * 3 / 4) - placeHoldersLen
  }

  function toByteArray (b64) {
    var tmp
    var lens = getLens(b64)
    var validLen = lens[0]
    var placeHoldersLen = lens[1]

    var arr = new Arr(_byteLength(b64, validLen, placeHoldersLen))

    var curByte = 0

    // if there are placeholders, only get up to the last complete 4 chars
    var len = placeHoldersLen > 0
      ? validLen - 4
      : validLen

    var i
    for (i = 0; i < len; i += 4) {
      tmp =
        (revLookup[b64.charCodeAt(i)] << 18) |
        (revLookup[b64.charCodeAt(i + 1)] << 12) |
        (revLookup[b64.charCodeAt(i + 2)] << 6) |
        revLookup[b64.charCodeAt(i + 3)]
      arr[curByte++] = (tmp >> 16) & 0xFF
      arr[curByte++] = (tmp >> 8) & 0xFF
      arr[curByte++] = tmp & 0xFF
    }

    if (placeHoldersLen === 2) {
      tmp =
        (revLookup[b64.charCodeAt(i)] << 2) |
        (revLookup[b64.charCodeAt(i + 1)] >> 4)
      arr[curByte++] = tmp & 0xFF
    }

    if (placeHoldersLen === 1) {
      tmp =
        (revLookup[b64.charCodeAt(i)] << 10) |
        (revLookup[b64.charCodeAt(i + 1)] << 4) |
        (revLookup[b64.charCodeAt(i + 2)] >> 2)
      arr[curByte++] = (tmp >> 8) & 0xFF
      arr[curByte++] = tmp & 0xFF
    }

    return arr
  }

  function tripletToBase64 (num) {
    return lookup[num >> 18 & 0x3F] +
      lookup[num >> 12 & 0x3F] +
      lookup[num >> 6 & 0x3F] +
      lookup[num & 0x3F]
  }

  function encodeChunk (uint8, start, end) {
    var tmp
    var output = []
    for (var i = start; i < end; i += 3) {
      tmp =
        ((uint8[i] << 16) & 0xFF0000) +
        ((uint8[i + 1] << 8) & 0xFF00) +
        (uint8[i + 2] & 0xFF)
      output.push(tripletToBase64(tmp))
    }
    return output.join('')
  }

  function fromByteArray (uint8) {
    var tmp
    var len = uint8.length
    var extraBytes = len % 3 // if we have 1 byte left, pad 2 bytes
    var parts = []
    var maxChunkLength = 16383 // must be multiple of 3

    // go through the array every three bytes, we'll deal with trailing stuff later
    for (var i = 0, len2 = len - extraBytes; i < len2; i += maxChunkLength) {
      parts.push(encodeChunk(uint8, i, (i + maxChunkLength) > len2 ? len2 : (i + maxChunkLength)))
    }

    // pad the end with zeros, but make sure to not forget the extra bytes
    if (extraBytes === 1) {
      tmp = uint8[len - 1]
      parts.push(
        lookup[tmp >> 2] +
        lookup[(tmp << 4) & 0x3F] +
        '=='
      )
    } else if (extraBytes === 2) {
      tmp = (uint8[len - 2] << 8) + uint8[len - 1]
      parts.push(
        lookup[tmp >> 10] +
        lookup[(tmp >> 4) & 0x3F] +
        lookup[(tmp << 2) & 0x3F] +
        '='
      )
    }

    return parts.join('')
  }

  },{}],57:[function(require,module,exports){
  (function (Buffer){(function (){
  /*!
   * The buffer module from node.js, for the browser.
   *
   * @author   Feross Aboukhadijeh <https://feross.org>
   * @license  MIT
   */
  /* eslint-disable no-proto */

  'use strict'

  var base64 = require('base64-js')
  var ieee754 = require('ieee754')

  exports.Buffer = Buffer
  exports.SlowBuffer = SlowBuffer
  exports.INSPECT_MAX_BYTES = 50

  var K_MAX_LENGTH = 0x7fffffff
  exports.kMaxLength = K_MAX_LENGTH

  /**
   * If `Buffer.TYPED_ARRAY_SUPPORT`:
   *   === true    Use Uint8Array implementation (fastest)
   *   === false   Print warning and recommend using `buffer` v4.x which has an Object
   *               implementation (most compatible, even IE6)
   *
   * Browsers that support typed arrays are IE 10+, Firefox 4+, Chrome 7+, Safari 5.1+,
   * Opera 11.6+, iOS 4.2+.
   *
   * We report that the browser does not support typed arrays if the are not subclassable
   * using __proto__. Firefox 4-29 lacks support for adding new properties to `Uint8Array`
   * (See: https://bugzilla.mozilla.org/show_bug.cgi?id=695438). IE 10 lacks support
   * for __proto__ and has a buggy typed array implementation.
   */
  Buffer.TYPED_ARRAY_SUPPORT = typedArraySupport()

  if (!Buffer.TYPED_ARRAY_SUPPORT && typeof console !== 'undefined' &&
      typeof console.error === 'function') {
    console.error(
      'This browser lacks typed array (Uint8Array) support which is required by ' +
      '`buffer` v5.x. Use `buffer` v4.x if you require old browser support.'
    )
  }

  function typedArraySupport () {
    // Can typed array instances can be augmented?
    try {
      var arr = new Uint8Array(1)
      arr.__proto__ = { __proto__: Uint8Array.prototype, foo: function () { return 42 } }
      return arr.foo() === 42
    } catch (e) {
      return false
    }
  }

  Object.defineProperty(Buffer.prototype, 'parent', {
    enumerable: true,
    get: function () {
      if (!Buffer.isBuffer(this)) return undefined
      return this.buffer
    }
  })

  Object.defineProperty(Buffer.prototype, 'offset', {
    enumerable: true,
    get: function () {
      if (!Buffer.isBuffer(this)) return undefined
      return this.byteOffset
    }
  })

  function createBuffer (length) {
    if (length > K_MAX_LENGTH) {
      throw new RangeError('The value "' + length + '" is invalid for option "size"')
    }
    // Return an augmented `Uint8Array` instance
    var buf = new Uint8Array(length)
    buf.__proto__ = Buffer.prototype
    return buf
  }

  /**
   * The Buffer constructor returns instances of `Uint8Array` that have their
   * prototype changed to `Buffer.prototype`. Furthermore, `Buffer` is a subclass of
   * `Uint8Array`, so the returned instances will have all the node `Buffer` methods
   * and the `Uint8Array` methods. Square bracket notation works as expected -- it
   * returns a single octet.
   *
   * The `Uint8Array` prototype remains unmodified.
   */

  function Buffer (arg, encodingOrOffset, length) {
    // Common case.
    if (typeof arg === 'number') {
      if (typeof encodingOrOffset === 'string') {
        throw new TypeError(
          'The "string" argument must be of type string. Received type number'
        )
      }
      return allocUnsafe(arg)
    }
    return from(arg, encodingOrOffset, length)
  }

  // Fix subarray() in ES2016. See: https://github.com/feross/buffer/pull/97
  if (typeof Symbol !== 'undefined' && Symbol.species != null &&
      Buffer[Symbol.species] === Buffer) {
    Object.defineProperty(Buffer, Symbol.species, {
      value: null,
      configurable: true,
      enumerable: false,
      writable: false
    })
  }

  Buffer.poolSize = 8192 // not used by this implementation

  function from (value, encodingOrOffset, length) {
    if (typeof value === 'string') {
      return fromString(value, encodingOrOffset)
    }

    if (ArrayBuffer.isView(value)) {
      return fromArrayLike(value)
    }

    if (value == null) {
      throw TypeError(
        'The first argument must be one of type string, Buffer, ArrayBuffer, Array, ' +
        'or Array-like Object. Received type ' + (typeof value)
      )
    }

    if (isInstance(value, ArrayBuffer) ||
        (value && isInstance(value.buffer, ArrayBuffer))) {
      return fromArrayBuffer(value, encodingOrOffset, length)
    }

    if (typeof value === 'number') {
      throw new TypeError(
        'The "value" argument must not be of type number. Received type number'
      )
    }

    var valueOf = value.valueOf && value.valueOf()
    if (valueOf != null && valueOf !== value) {
      return Buffer.from(valueOf, encodingOrOffset, length)
    }

    var b = fromObject(value)
    if (b) return b

    if (typeof Symbol !== 'undefined' && Symbol.toPrimitive != null &&
        typeof value[Symbol.toPrimitive] === 'function') {
      return Buffer.from(
        value[Symbol.toPrimitive]('string'), encodingOrOffset, length
      )
    }

    throw new TypeError(
      'The first argument must be one of type string, Buffer, ArrayBuffer, Array, ' +
      'or Array-like Object. Received type ' + (typeof value)
    )
  }

  /**
   * Functionally equivalent to Buffer(arg, encoding) but throws a TypeError
   * if value is a number.
   * Buffer.from(str[, encoding])
   * Buffer.from(array)
   * Buffer.from(buffer)
   * Buffer.from(arrayBuffer[, byteOffset[, length]])
   **/
  Buffer.from = function (value, encodingOrOffset, length) {
    return from(value, encodingOrOffset, length)
  }

  // Note: Change prototype *after* Buffer.from is defined to workaround Chrome bug:
  // https://github.com/feross/buffer/pull/148
  Buffer.prototype.__proto__ = Uint8Array.prototype
  Buffer.__proto__ = Uint8Array

  function assertSize (size) {
    if (typeof size !== 'number') {
      throw new TypeError('"size" argument must be of type number')
    } else if (size < 0) {
      throw new RangeError('The value "' + size + '" is invalid for option "size"')
    }
  }

  function alloc (size, fill, encoding) {
    assertSize(size)
    if (size <= 0) {
      return createBuffer(size)
    }
    if (fill !== undefined) {
      // Only pay attention to encoding if it's a string. This
      // prevents accidentally sending in a number that would
      // be interpretted as a start offset.
      return typeof encoding === 'string'
        ? createBuffer(size).fill(fill, encoding)
        : createBuffer(size).fill(fill)
    }
    return createBuffer(size)
  }

  /**
   * Creates a new filled Buffer instance.
   * alloc(size[, fill[, encoding]])
   **/
  Buffer.alloc = function (size, fill, encoding) {
    return alloc(size, fill, encoding)
  }

  function allocUnsafe (size) {
    assertSize(size)
    return createBuffer(size < 0 ? 0 : checked(size) | 0)
  }

  /**
   * Equivalent to Buffer(num), by default creates a non-zero-filled Buffer instance.
   * */
  Buffer.allocUnsafe = function (size) {
    return allocUnsafe(size)
  }
  /**
   * Equivalent to SlowBuffer(num), by default creates a non-zero-filled Buffer instance.
   */
  Buffer.allocUnsafeSlow = function (size) {
    return allocUnsafe(size)
  }

  function fromString (string, encoding) {
    if (typeof encoding !== 'string' || encoding === '') {
      encoding = 'utf8'
    }

    if (!Buffer.isEncoding(encoding)) {
      throw new TypeError('Unknown encoding: ' + encoding)
    }

    var length = byteLength(string, encoding) | 0
    var buf = createBuffer(length)

    var actual = buf.write(string, encoding)

    if (actual !== length) {
      // Writing a hex string, for example, that contains invalid characters will
      // cause everything after the first invalid character to be ignored. (e.g.
      // 'abxxcd' will be treated as 'ab')
      buf = buf.slice(0, actual)
    }

    return buf
  }

  function fromArrayLike (array) {
    var length = array.length < 0 ? 0 : checked(array.length) | 0
    var buf = createBuffer(length)
    for (var i = 0; i < length; i += 1) {
      buf[i] = array[i] & 255
    }
    return buf
  }

  function fromArrayBuffer (array, byteOffset, length) {
    if (byteOffset < 0 || array.byteLength < byteOffset) {
      throw new RangeError('"offset" is outside of buffer bounds')
    }

    if (array.byteLength < byteOffset + (length || 0)) {
      throw new RangeError('"length" is outside of buffer bounds')
    }

    var buf
    if (byteOffset === undefined && length === undefined) {
      buf = new Uint8Array(array)
    } else if (length === undefined) {
      buf = new Uint8Array(array, byteOffset)
    } else {
      buf = new Uint8Array(array, byteOffset, length)
    }

    // Return an augmented `Uint8Array` instance
    buf.__proto__ = Buffer.prototype
    return buf
  }

  function fromObject (obj) {
    if (Buffer.isBuffer(obj)) {
      var len = checked(obj.length) | 0
      var buf = createBuffer(len)

      if (buf.length === 0) {
        return buf
      }

      obj.copy(buf, 0, 0, len)
      return buf
    }

    if (obj.length !== undefined) {
      if (typeof obj.length !== 'number' || numberIsNaN(obj.length)) {
        return createBuffer(0)
      }
      return fromArrayLike(obj)
    }

    if (obj.type === 'Buffer' && Array.isArray(obj.data)) {
      return fromArrayLike(obj.data)
    }
  }

  function checked (length) {
    // Note: cannot use `length < K_MAX_LENGTH` here because that fails when
    // length is NaN (which is otherwise coerced to zero.)
    if (length >= K_MAX_LENGTH) {
      throw new RangeError('Attempt to allocate Buffer larger than maximum ' +
                           'size: 0x' + K_MAX_LENGTH.toString(16) + ' bytes')
    }
    return length | 0
  }

  function SlowBuffer (length) {
    if (+length != length) { // eslint-disable-line eqeqeq
      length = 0
    }
    return Buffer.alloc(+length)
  }

  Buffer.isBuffer = function isBuffer (b) {
    return b != null && b._isBuffer === true &&
      b !== Buffer.prototype // so Buffer.isBuffer(Buffer.prototype) will be false
  }

  Buffer.compare = function compare (a, b) {
    if (isInstance(a, Uint8Array)) a = Buffer.from(a, a.offset, a.byteLength)
    if (isInstance(b, Uint8Array)) b = Buffer.from(b, b.offset, b.byteLength)
    if (!Buffer.isBuffer(a) || !Buffer.isBuffer(b)) {
      throw new TypeError(
        'The "buf1", "buf2" arguments must be one of type Buffer or Uint8Array'
      )
    }

    if (a === b) return 0

    var x = a.length
    var y = b.length

    for (var i = 0, len = Math.min(x, y); i < len; ++i) {
      if (a[i] !== b[i]) {
        x = a[i]
        y = b[i]
        break
      }
    }

    if (x < y) return -1
    if (y < x) return 1
    return 0
  }

  Buffer.isEncoding = function isEncoding (encoding) {
    switch (String(encoding).toLowerCase()) {
      case 'hex':
      case 'utf8':
      case 'utf-8':
      case 'ascii':
      case 'latin1':
      case 'binary':
      case 'base64':
      case 'ucs2':
      case 'ucs-2':
      case 'utf16le':
      case 'utf-16le':
        return true
      default:
        return false
    }
  }

  Buffer.concat = function concat (list, length) {
    if (!Array.isArray(list)) {
      throw new TypeError('"list" argument must be an Array of Buffers')
    }

    if (list.length === 0) {
      return Buffer.alloc(0)
    }

    var i
    if (length === undefined) {
      length = 0
      for (i = 0; i < list.length; ++i) {
        length += list[i].length
      }
    }

    var buffer = Buffer.allocUnsafe(length)
    var pos = 0
    for (i = 0; i < list.length; ++i) {
      var buf = list[i]
      if (isInstance(buf, Uint8Array)) {
        buf = Buffer.from(buf)
      }
      if (!Buffer.isBuffer(buf)) {
        throw new TypeError('"list" argument must be an Array of Buffers')
      }
      buf.copy(buffer, pos)
      pos += buf.length
    }
    return buffer
  }

  function byteLength (string, encoding) {
    if (Buffer.isBuffer(string)) {
      return string.length
    }
    if (ArrayBuffer.isView(string) || isInstance(string, ArrayBuffer)) {
      return string.byteLength
    }
    if (typeof string !== 'string') {
      throw new TypeError(
        'The "string" argument must be one of type string, Buffer, or ArrayBuffer. ' +
        'Received type ' + typeof string
      )
    }

    var len = string.length
    var mustMatch = (arguments.length > 2 && arguments[2] === true)
    if (!mustMatch && len === 0) return 0

    // Use a for loop to avoid recursion
    var loweredCase = false
    for (;;) {
      switch (encoding) {
        case 'ascii':
        case 'latin1':
        case 'binary':
          return len
        case 'utf8':
        case 'utf-8':
          return utf8ToBytes(string).length
        case 'ucs2':
        case 'ucs-2':
        case 'utf16le':
        case 'utf-16le':
          return len * 2
        case 'hex':
          return len >>> 1
        case 'base64':
          return base64ToBytes(string).length
        default:
          if (loweredCase) {
            return mustMatch ? -1 : utf8ToBytes(string).length // assume utf8
          }
          encoding = ('' + encoding).toLowerCase()
          loweredCase = true
      }
    }
  }
  Buffer.byteLength = byteLength

  function slowToString (encoding, start, end) {
    var loweredCase = false

    // No need to verify that "this.length <= MAX_UINT32" since it's a read-only
    // property of a typed array.

    // This behaves neither like String nor Uint8Array in that we set start/end
    // to their upper/lower bounds if the value passed is out of range.
    // undefined is handled specially as per ECMA-262 6th Edition,
    // Section 13.3.3.7 Runtime Semantics: KeyedBindingInitialization.
    if (start === undefined || start < 0) {
      start = 0
    }
    // Return early if start > this.length. Done here to prevent potential uint32
    // coercion fail below.
    if (start > this.length) {
      return ''
    }

    if (end === undefined || end > this.length) {
      end = this.length
    }

    if (end <= 0) {
      return ''
    }

    // Force coersion to uint32. This will also coerce falsey/NaN values to 0.
    end >>>= 0
    start >>>= 0

    if (end <= start) {
      return ''
    }

    if (!encoding) encoding = 'utf8'

    while (true) {
      switch (encoding) {
        case 'hex':
          return hexSlice(this, start, end)

        case 'utf8':
        case 'utf-8':
          return utf8Slice(this, start, end)

        case 'ascii':
          return asciiSlice(this, start, end)

        case 'latin1':
        case 'binary':
          return latin1Slice(this, start, end)

        case 'base64':
          return base64Slice(this, start, end)

        case 'ucs2':
        case 'ucs-2':
        case 'utf16le':
        case 'utf-16le':
          return utf16leSlice(this, start, end)

        default:
          if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
          encoding = (encoding + '').toLowerCase()
          loweredCase = true
      }
    }
  }

  // This property is used by `Buffer.isBuffer` (and the `is-buffer` npm package)
  // to detect a Buffer instance. It's not possible to use `instanceof Buffer`
  // reliably in a browserify context because there could be multiple different
  // copies of the 'buffer' package in use. This method works even for Buffer
  // instances that were created from another copy of the `buffer` package.
  // See: https://github.com/feross/buffer/issues/154
  Buffer.prototype._isBuffer = true

  function swap (b, n, m) {
    var i = b[n]
    b[n] = b[m]
    b[m] = i
  }

  Buffer.prototype.swap16 = function swap16 () {
    var len = this.length
    if (len % 2 !== 0) {
      throw new RangeError('Buffer size must be a multiple of 16-bits')
    }
    for (var i = 0; i < len; i += 2) {
      swap(this, i, i + 1)
    }
    return this
  }

  Buffer.prototype.swap32 = function swap32 () {
    var len = this.length
    if (len % 4 !== 0) {
      throw new RangeError('Buffer size must be a multiple of 32-bits')
    }
    for (var i = 0; i < len; i += 4) {
      swap(this, i, i + 3)
      swap(this, i + 1, i + 2)
    }
    return this
  }

  Buffer.prototype.swap64 = function swap64 () {
    var len = this.length
    if (len % 8 !== 0) {
      throw new RangeError('Buffer size must be a multiple of 64-bits')
    }
    for (var i = 0; i < len; i += 8) {
      swap(this, i, i + 7)
      swap(this, i + 1, i + 6)
      swap(this, i + 2, i + 5)
      swap(this, i + 3, i + 4)
    }
    return this
  }

  Buffer.prototype.toString = function toString () {
    var length = this.length
    if (length === 0) return ''
    if (arguments.length === 0) return utf8Slice(this, 0, length)
    return slowToString.apply(this, arguments)
  }

  Buffer.prototype.toLocaleString = Buffer.prototype.toString

  Buffer.prototype.equals = function equals (b) {
    if (!Buffer.isBuffer(b)) throw new TypeError('Argument must be a Buffer')
    if (this === b) return true
    return Buffer.compare(this, b) === 0
  }

  Buffer.prototype.inspect = function inspect () {
    var str = ''
    var max = exports.INSPECT_MAX_BYTES
    str = this.toString('hex', 0, max).replace(/(.{2})/g, '$1 ').trim()
    if (this.length > max) str += ' ... '
    return '<Buffer ' + str + '>'
  }

  Buffer.prototype.compare = function compare (target, start, end, thisStart, thisEnd) {
    if (isInstance(target, Uint8Array)) {
      target = Buffer.from(target, target.offset, target.byteLength)
    }
    if (!Buffer.isBuffer(target)) {
      throw new TypeError(
        'The "target" argument must be one of type Buffer or Uint8Array. ' +
        'Received type ' + (typeof target)
      )
    }

    if (start === undefined) {
      start = 0
    }
    if (end === undefined) {
      end = target ? target.length : 0
    }
    if (thisStart === undefined) {
      thisStart = 0
    }
    if (thisEnd === undefined) {
      thisEnd = this.length
    }

    if (start < 0 || end > target.length || thisStart < 0 || thisEnd > this.length) {
      throw new RangeError('out of range index')
    }

    if (thisStart >= thisEnd && start >= end) {
      return 0
    }
    if (thisStart >= thisEnd) {
      return -1
    }
    if (start >= end) {
      return 1
    }

    start >>>= 0
    end >>>= 0
    thisStart >>>= 0
    thisEnd >>>= 0

    if (this === target) return 0

    var x = thisEnd - thisStart
    var y = end - start
    var len = Math.min(x, y)

    var thisCopy = this.slice(thisStart, thisEnd)
    var targetCopy = target.slice(start, end)

    for (var i = 0; i < len; ++i) {
      if (thisCopy[i] !== targetCopy[i]) {
        x = thisCopy[i]
        y = targetCopy[i]
        break
      }
    }

    if (x < y) return -1
    if (y < x) return 1
    return 0
  }

  // Finds either the first index of `val` in `buffer` at offset >= `byteOffset`,
  // OR the last index of `val` in `buffer` at offset <= `byteOffset`.
  //
  // Arguments:
  // - buffer - a Buffer to search
  // - val - a string, Buffer, or number
  // - byteOffset - an index into `buffer`; will be clamped to an int32
  // - encoding - an optional encoding, relevant is val is a string
  // - dir - true for indexOf, false for lastIndexOf
  function bidirectionalIndexOf (buffer, val, byteOffset, encoding, dir) {
    // Empty buffer means no match
    if (buffer.length === 0) return -1

    // Normalize byteOffset
    if (typeof byteOffset === 'string') {
      encoding = byteOffset
      byteOffset = 0
    } else if (byteOffset > 0x7fffffff) {
      byteOffset = 0x7fffffff
    } else if (byteOffset < -0x80000000) {
      byteOffset = -0x80000000
    }
    byteOffset = +byteOffset // Coerce to Number.
    if (numberIsNaN(byteOffset)) {
      // byteOffset: it it's undefined, null, NaN, "foo", etc, search whole buffer
      byteOffset = dir ? 0 : (buffer.length - 1)
    }

    // Normalize byteOffset: negative offsets start from the end of the buffer
    if (byteOffset < 0) byteOffset = buffer.length + byteOffset
    if (byteOffset >= buffer.length) {
      if (dir) return -1
      else byteOffset = buffer.length - 1
    } else if (byteOffset < 0) {
      if (dir) byteOffset = 0
      else return -1
    }

    // Normalize val
    if (typeof val === 'string') {
      val = Buffer.from(val, encoding)
    }

    // Finally, search either indexOf (if dir is true) or lastIndexOf
    if (Buffer.isBuffer(val)) {
      // Special case: looking for empty string/buffer always fails
      if (val.length === 0) {
        return -1
      }
      return arrayIndexOf(buffer, val, byteOffset, encoding, dir)
    } else if (typeof val === 'number') {
      val = val & 0xFF // Search for a byte value [0-255]
      if (typeof Uint8Array.prototype.indexOf === 'function') {
        if (dir) {
          return Uint8Array.prototype.indexOf.call(buffer, val, byteOffset)
        } else {
          return Uint8Array.prototype.lastIndexOf.call(buffer, val, byteOffset)
        }
      }
      return arrayIndexOf(buffer, [ val ], byteOffset, encoding, dir)
    }

    throw new TypeError('val must be string, number or Buffer')
  }

  function arrayIndexOf (arr, val, byteOffset, encoding, dir) {
    var indexSize = 1
    var arrLength = arr.length
    var valLength = val.length

    if (encoding !== undefined) {
      encoding = String(encoding).toLowerCase()
      if (encoding === 'ucs2' || encoding === 'ucs-2' ||
          encoding === 'utf16le' || encoding === 'utf-16le') {
        if (arr.length < 2 || val.length < 2) {
          return -1
        }
        indexSize = 2
        arrLength /= 2
        valLength /= 2
        byteOffset /= 2
      }
    }

    function read (buf, i) {
      if (indexSize === 1) {
        return buf[i]
      } else {
        return buf.readUInt16BE(i * indexSize)
      }
    }

    var i
    if (dir) {
      var foundIndex = -1
      for (i = byteOffset; i < arrLength; i++) {
        if (read(arr, i) === read(val, foundIndex === -1 ? 0 : i - foundIndex)) {
          if (foundIndex === -1) foundIndex = i
          if (i - foundIndex + 1 === valLength) return foundIndex * indexSize
        } else {
          if (foundIndex !== -1) i -= i - foundIndex
          foundIndex = -1
        }
      }
    } else {
      if (byteOffset + valLength > arrLength) byteOffset = arrLength - valLength
      for (i = byteOffset; i >= 0; i--) {
        var found = true
        for (var j = 0; j < valLength; j++) {
          if (read(arr, i + j) !== read(val, j)) {
            found = false
            break
          }
        }
        if (found) return i
      }
    }

    return -1
  }

  Buffer.prototype.includes = function includes (val, byteOffset, encoding) {
    return this.indexOf(val, byteOffset, encoding) !== -1
  }

  Buffer.prototype.indexOf = function indexOf (val, byteOffset, encoding) {
    return bidirectionalIndexOf(this, val, byteOffset, encoding, true)
  }

  Buffer.prototype.lastIndexOf = function lastIndexOf (val, byteOffset, encoding) {
    return bidirectionalIndexOf(this, val, byteOffset, encoding, false)
  }

  function hexWrite (buf, string, offset, length) {
    offset = Number(offset) || 0
    var remaining = buf.length - offset
    if (!length) {
      length = remaining
    } else {
      length = Number(length)
      if (length > remaining) {
        length = remaining
      }
    }

    var strLen = string.length

    if (length > strLen / 2) {
      length = strLen / 2
    }
    for (var i = 0; i < length; ++i) {
      var parsed = parseInt(string.substr(i * 2, 2), 16)
      if (numberIsNaN(parsed)) return i
      buf[offset + i] = parsed
    }
    return i
  }

  function utf8Write (buf, string, offset, length) {
    return blitBuffer(utf8ToBytes(string, buf.length - offset), buf, offset, length)
  }

  function asciiWrite (buf, string, offset, length) {
    return blitBuffer(asciiToBytes(string), buf, offset, length)
  }

  function latin1Write (buf, string, offset, length) {
    return asciiWrite(buf, string, offset, length)
  }

  function base64Write (buf, string, offset, length) {
    return blitBuffer(base64ToBytes(string), buf, offset, length)
  }

  function ucs2Write (buf, string, offset, length) {
    return blitBuffer(utf16leToBytes(string, buf.length - offset), buf, offset, length)
  }

  Buffer.prototype.write = function write (string, offset, length, encoding) {
    // Buffer#write(string)
    if (offset === undefined) {
      encoding = 'utf8'
      length = this.length
      offset = 0
    // Buffer#write(string, encoding)
    } else if (length === undefined && typeof offset === 'string') {
      encoding = offset
      length = this.length
      offset = 0
    // Buffer#write(string, offset[, length][, encoding])
    } else if (isFinite(offset)) {
      offset = offset >>> 0
      if (isFinite(length)) {
        length = length >>> 0
        if (encoding === undefined) encoding = 'utf8'
      } else {
        encoding = length
        length = undefined
      }
    } else {
      throw new Error(
        'Buffer.write(string, encoding, offset[, length]) is no longer supported'
      )
    }

    var remaining = this.length - offset
    if (length === undefined || length > remaining) length = remaining

    if ((string.length > 0 && (length < 0 || offset < 0)) || offset > this.length) {
      throw new RangeError('Attempt to write outside buffer bounds')
    }

    if (!encoding) encoding = 'utf8'

    var loweredCase = false
    for (;;) {
      switch (encoding) {
        case 'hex':
          return hexWrite(this, string, offset, length)

        case 'utf8':
        case 'utf-8':
          return utf8Write(this, string, offset, length)

        case 'ascii':
          return asciiWrite(this, string, offset, length)

        case 'latin1':
        case 'binary':
          return latin1Write(this, string, offset, length)

        case 'base64':
          // Warning: maxLength not taken into account in base64Write
          return base64Write(this, string, offset, length)

        case 'ucs2':
        case 'ucs-2':
        case 'utf16le':
        case 'utf-16le':
          return ucs2Write(this, string, offset, length)

        default:
          if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
          encoding = ('' + encoding).toLowerCase()
          loweredCase = true
      }
    }
  }

  Buffer.prototype.toJSON = function toJSON () {
    return {
      type: 'Buffer',
      data: Array.prototype.slice.call(this._arr || this, 0)
    }
  }

  function base64Slice (buf, start, end) {
    if (start === 0 && end === buf.length) {
      return base64.fromByteArray(buf)
    } else {
      return base64.fromByteArray(buf.slice(start, end))
    }
  }

  function utf8Slice (buf, start, end) {
    end = Math.min(buf.length, end)
    var res = []

    var i = start
    while (i < end) {
      var firstByte = buf[i]
      var codePoint = null
      var bytesPerSequence = (firstByte > 0xEF) ? 4
        : (firstByte > 0xDF) ? 3
          : (firstByte > 0xBF) ? 2
            : 1

      if (i + bytesPerSequence <= end) {
        var secondByte, thirdByte, fourthByte, tempCodePoint

        switch (bytesPerSequence) {
          case 1:
            if (firstByte < 0x80) {
              codePoint = firstByte
            }
            break
          case 2:
            secondByte = buf[i + 1]
            if ((secondByte & 0xC0) === 0x80) {
              tempCodePoint = (firstByte & 0x1F) << 0x6 | (secondByte & 0x3F)
              if (tempCodePoint > 0x7F) {
                codePoint = tempCodePoint
              }
            }
            break
          case 3:
            secondByte = buf[i + 1]
            thirdByte = buf[i + 2]
            if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80) {
              tempCodePoint = (firstByte & 0xF) << 0xC | (secondByte & 0x3F) << 0x6 | (thirdByte & 0x3F)
              if (tempCodePoint > 0x7FF && (tempCodePoint < 0xD800 || tempCodePoint > 0xDFFF)) {
                codePoint = tempCodePoint
              }
            }
            break
          case 4:
            secondByte = buf[i + 1]
            thirdByte = buf[i + 2]
            fourthByte = buf[i + 3]
            if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80 && (fourthByte & 0xC0) === 0x80) {
              tempCodePoint = (firstByte & 0xF) << 0x12 | (secondByte & 0x3F) << 0xC | (thirdByte & 0x3F) << 0x6 | (fourthByte & 0x3F)
              if (tempCodePoint > 0xFFFF && tempCodePoint < 0x110000) {
                codePoint = tempCodePoint
              }
            }
        }
      }

      if (codePoint === null) {
        // we did not generate a valid codePoint so insert a
        // replacement char (U+FFFD) and advance only 1 byte
        codePoint = 0xFFFD
        bytesPerSequence = 1
      } else if (codePoint > 0xFFFF) {
        // encode to utf16 (surrogate pair dance)
        codePoint -= 0x10000
        res.push(codePoint >>> 10 & 0x3FF | 0xD800)
        codePoint = 0xDC00 | codePoint & 0x3FF
      }

      res.push(codePoint)
      i += bytesPerSequence
    }

    return decodeCodePointsArray(res)
  }

  // Based on http://stackoverflow.com/a/22747272/680742, the browser with
  // the lowest limit is Chrome, with 0x10000 args.
  // We go 1 magnitude less, for safety
  var MAX_ARGUMENTS_LENGTH = 0x1000

  function decodeCodePointsArray (codePoints) {
    var len = codePoints.length
    if (len <= MAX_ARGUMENTS_LENGTH) {
      return String.fromCharCode.apply(String, codePoints) // avoid extra slice()
    }

    // Decode in chunks to avoid "call stack size exceeded".
    var res = ''
    var i = 0
    while (i < len) {
      res += String.fromCharCode.apply(
        String,
        codePoints.slice(i, i += MAX_ARGUMENTS_LENGTH)
      )
    }
    return res
  }

  function asciiSlice (buf, start, end) {
    var ret = ''
    end = Math.min(buf.length, end)

    for (var i = start; i < end; ++i) {
      ret += String.fromCharCode(buf[i] & 0x7F)
    }
    return ret
  }

  function latin1Slice (buf, start, end) {
    var ret = ''
    end = Math.min(buf.length, end)

    for (var i = start; i < end; ++i) {
      ret += String.fromCharCode(buf[i])
    }
    return ret
  }

  function hexSlice (buf, start, end) {
    var len = buf.length

    if (!start || start < 0) start = 0
    if (!end || end < 0 || end > len) end = len

    var out = ''
    for (var i = start; i < end; ++i) {
      out += toHex(buf[i])
    }
    return out
  }

  function utf16leSlice (buf, start, end) {
    var bytes = buf.slice(start, end)
    var res = ''
    for (var i = 0; i < bytes.length; i += 2) {
      res += String.fromCharCode(bytes[i] + (bytes[i + 1] * 256))
    }
    return res
  }

  Buffer.prototype.slice = function slice (start, end) {
    var len = this.length
    start = ~~start
    end = end === undefined ? len : ~~end

    if (start < 0) {
      start += len
      if (start < 0) start = 0
    } else if (start > len) {
      start = len
    }

    if (end < 0) {
      end += len
      if (end < 0) end = 0
    } else if (end > len) {
      end = len
    }

    if (end < start) end = start

    var newBuf = this.subarray(start, end)
    // Return an augmented `Uint8Array` instance
    newBuf.__proto__ = Buffer.prototype
    return newBuf
  }

  /*
   * Need to make sure that buffer isn't trying to write out of bounds.
   */
  function checkOffset (offset, ext, length) {
    if ((offset % 1) !== 0 || offset < 0) throw new RangeError('offset is not uint')
    if (offset + ext > length) throw new RangeError('Trying to access beyond buffer length')
  }

  Buffer.prototype.readUIntLE = function readUIntLE (offset, byteLength, noAssert) {
    offset = offset >>> 0
    byteLength = byteLength >>> 0
    if (!noAssert) checkOffset(offset, byteLength, this.length)

    var val = this[offset]
    var mul = 1
    var i = 0
    while (++i < byteLength && (mul *= 0x100)) {
      val += this[offset + i] * mul
    }

    return val
  }

  Buffer.prototype.readUIntBE = function readUIntBE (offset, byteLength, noAssert) {
    offset = offset >>> 0
    byteLength = byteLength >>> 0
    if (!noAssert) {
      checkOffset(offset, byteLength, this.length)
    }

    var val = this[offset + --byteLength]
    var mul = 1
    while (byteLength > 0 && (mul *= 0x100)) {
      val += this[offset + --byteLength] * mul
    }

    return val
  }

  Buffer.prototype.readUInt8 = function readUInt8 (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 1, this.length)
    return this[offset]
  }

  Buffer.prototype.readUInt16LE = function readUInt16LE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 2, this.length)
    return this[offset] | (this[offset + 1] << 8)
  }

  Buffer.prototype.readUInt16BE = function readUInt16BE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 2, this.length)
    return (this[offset] << 8) | this[offset + 1]
  }

  Buffer.prototype.readUInt32LE = function readUInt32LE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 4, this.length)

    return ((this[offset]) |
        (this[offset + 1] << 8) |
        (this[offset + 2] << 16)) +
        (this[offset + 3] * 0x1000000)
  }

  Buffer.prototype.readUInt32BE = function readUInt32BE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 4, this.length)

    return (this[offset] * 0x1000000) +
      ((this[offset + 1] << 16) |
      (this[offset + 2] << 8) |
      this[offset + 3])
  }

  Buffer.prototype.readIntLE = function readIntLE (offset, byteLength, noAssert) {
    offset = offset >>> 0
    byteLength = byteLength >>> 0
    if (!noAssert) checkOffset(offset, byteLength, this.length)

    var val = this[offset]
    var mul = 1
    var i = 0
    while (++i < byteLength && (mul *= 0x100)) {
      val += this[offset + i] * mul
    }
    mul *= 0x80

    if (val >= mul) val -= Math.pow(2, 8 * byteLength)

    return val
  }

  Buffer.prototype.readIntBE = function readIntBE (offset, byteLength, noAssert) {
    offset = offset >>> 0
    byteLength = byteLength >>> 0
    if (!noAssert) checkOffset(offset, byteLength, this.length)

    var i = byteLength
    var mul = 1
    var val = this[offset + --i]
    while (i > 0 && (mul *= 0x100)) {
      val += this[offset + --i] * mul
    }
    mul *= 0x80

    if (val >= mul) val -= Math.pow(2, 8 * byteLength)

    return val
  }

  Buffer.prototype.readInt8 = function readInt8 (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 1, this.length)
    if (!(this[offset] & 0x80)) return (this[offset])
    return ((0xff - this[offset] + 1) * -1)
  }

  Buffer.prototype.readInt16LE = function readInt16LE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 2, this.length)
    var val = this[offset] | (this[offset + 1] << 8)
    return (val & 0x8000) ? val | 0xFFFF0000 : val
  }

  Buffer.prototype.readInt16BE = function readInt16BE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 2, this.length)
    var val = this[offset + 1] | (this[offset] << 8)
    return (val & 0x8000) ? val | 0xFFFF0000 : val
  }

  Buffer.prototype.readInt32LE = function readInt32LE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 4, this.length)

    return (this[offset]) |
      (this[offset + 1] << 8) |
      (this[offset + 2] << 16) |
      (this[offset + 3] << 24)
  }

  Buffer.prototype.readInt32BE = function readInt32BE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 4, this.length)

    return (this[offset] << 24) |
      (this[offset + 1] << 16) |
      (this[offset + 2] << 8) |
      (this[offset + 3])
  }

  Buffer.prototype.readFloatLE = function readFloatLE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 4, this.length)
    return ieee754.read(this, offset, true, 23, 4)
  }

  Buffer.prototype.readFloatBE = function readFloatBE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 4, this.length)
    return ieee754.read(this, offset, false, 23, 4)
  }

  Buffer.prototype.readDoubleLE = function readDoubleLE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 8, this.length)
    return ieee754.read(this, offset, true, 52, 8)
  }

  Buffer.prototype.readDoubleBE = function readDoubleBE (offset, noAssert) {
    offset = offset >>> 0
    if (!noAssert) checkOffset(offset, 8, this.length)
    return ieee754.read(this, offset, false, 52, 8)
  }

  function checkInt (buf, value, offset, ext, max, min) {
    if (!Buffer.isBuffer(buf)) throw new TypeError('"buffer" argument must be a Buffer instance')
    if (value > max || value < min) throw new RangeError('"value" argument is out of bounds')
    if (offset + ext > buf.length) throw new RangeError('Index out of range')
  }

  Buffer.prototype.writeUIntLE = function writeUIntLE (value, offset, byteLength, noAssert) {
    value = +value
    offset = offset >>> 0
    byteLength = byteLength >>> 0
    if (!noAssert) {
      var maxBytes = Math.pow(2, 8 * byteLength) - 1
      checkInt(this, value, offset, byteLength, maxBytes, 0)
    }

    var mul = 1
    var i = 0
    this[offset] = value & 0xFF
    while (++i < byteLength && (mul *= 0x100)) {
      this[offset + i] = (value / mul) & 0xFF
    }

    return offset + byteLength
  }

  Buffer.prototype.writeUIntBE = function writeUIntBE (value, offset, byteLength, noAssert) {
    value = +value
    offset = offset >>> 0
    byteLength = byteLength >>> 0
    if (!noAssert) {
      var maxBytes = Math.pow(2, 8 * byteLength) - 1
      checkInt(this, value, offset, byteLength, maxBytes, 0)
    }

    var i = byteLength - 1
    var mul = 1
    this[offset + i] = value & 0xFF
    while (--i >= 0 && (mul *= 0x100)) {
      this[offset + i] = (value / mul) & 0xFF
    }

    return offset + byteLength
  }

  Buffer.prototype.writeUInt8 = function writeUInt8 (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 1, 0xff, 0)
    this[offset] = (value & 0xff)
    return offset + 1
  }

  Buffer.prototype.writeUInt16LE = function writeUInt16LE (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0)
    this[offset] = (value & 0xff)
    this[offset + 1] = (value >>> 8)
    return offset + 2
  }

  Buffer.prototype.writeUInt16BE = function writeUInt16BE (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0)
    this[offset] = (value >>> 8)
    this[offset + 1] = (value & 0xff)
    return offset + 2
  }

  Buffer.prototype.writeUInt32LE = function writeUInt32LE (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0)
    this[offset + 3] = (value >>> 24)
    this[offset + 2] = (value >>> 16)
    this[offset + 1] = (value >>> 8)
    this[offset] = (value & 0xff)
    return offset + 4
  }

  Buffer.prototype.writeUInt32BE = function writeUInt32BE (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0)
    this[offset] = (value >>> 24)
    this[offset + 1] = (value >>> 16)
    this[offset + 2] = (value >>> 8)
    this[offset + 3] = (value & 0xff)
    return offset + 4
  }

  Buffer.prototype.writeIntLE = function writeIntLE (value, offset, byteLength, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) {
      var limit = Math.pow(2, (8 * byteLength) - 1)

      checkInt(this, value, offset, byteLength, limit - 1, -limit)
    }

    var i = 0
    var mul = 1
    var sub = 0
    this[offset] = value & 0xFF
    while (++i < byteLength && (mul *= 0x100)) {
      if (value < 0 && sub === 0 && this[offset + i - 1] !== 0) {
        sub = 1
      }
      this[offset + i] = ((value / mul) >> 0) - sub & 0xFF
    }

    return offset + byteLength
  }

  Buffer.prototype.writeIntBE = function writeIntBE (value, offset, byteLength, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) {
      var limit = Math.pow(2, (8 * byteLength) - 1)

      checkInt(this, value, offset, byteLength, limit - 1, -limit)
    }

    var i = byteLength - 1
    var mul = 1
    var sub = 0
    this[offset + i] = value & 0xFF
    while (--i >= 0 && (mul *= 0x100)) {
      if (value < 0 && sub === 0 && this[offset + i + 1] !== 0) {
        sub = 1
      }
      this[offset + i] = ((value / mul) >> 0) - sub & 0xFF
    }

    return offset + byteLength
  }

  Buffer.prototype.writeInt8 = function writeInt8 (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 1, 0x7f, -0x80)
    if (value < 0) value = 0xff + value + 1
    this[offset] = (value & 0xff)
    return offset + 1
  }

  Buffer.prototype.writeInt16LE = function writeInt16LE (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -0x8000)
    this[offset] = (value & 0xff)
    this[offset + 1] = (value >>> 8)
    return offset + 2
  }

  Buffer.prototype.writeInt16BE = function writeInt16BE (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -0x8000)
    this[offset] = (value >>> 8)
    this[offset + 1] = (value & 0xff)
    return offset + 2
  }

  Buffer.prototype.writeInt32LE = function writeInt32LE (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -0x80000000)
    this[offset] = (value & 0xff)
    this[offset + 1] = (value >>> 8)
    this[offset + 2] = (value >>> 16)
    this[offset + 3] = (value >>> 24)
    return offset + 4
  }

  Buffer.prototype.writeInt32BE = function writeInt32BE (value, offset, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -0x80000000)
    if (value < 0) value = 0xffffffff + value + 1
    this[offset] = (value >>> 24)
    this[offset + 1] = (value >>> 16)
    this[offset + 2] = (value >>> 8)
    this[offset + 3] = (value & 0xff)
    return offset + 4
  }

  function checkIEEE754 (buf, value, offset, ext, max, min) {
    if (offset + ext > buf.length) throw new RangeError('Index out of range')
    if (offset < 0) throw new RangeError('Index out of range')
  }

  function writeFloat (buf, value, offset, littleEndian, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) {
      checkIEEE754(buf, value, offset, 4, 3.4028234663852886e+38, -3.4028234663852886e+38)
    }
    ieee754.write(buf, value, offset, littleEndian, 23, 4)
    return offset + 4
  }

  Buffer.prototype.writeFloatLE = function writeFloatLE (value, offset, noAssert) {
    return writeFloat(this, value, offset, true, noAssert)
  }

  Buffer.prototype.writeFloatBE = function writeFloatBE (value, offset, noAssert) {
    return writeFloat(this, value, offset, false, noAssert)
  }

  function writeDouble (buf, value, offset, littleEndian, noAssert) {
    value = +value
    offset = offset >>> 0
    if (!noAssert) {
      checkIEEE754(buf, value, offset, 8, 1.7976931348623157E+308, -1.7976931348623157E+308)
    }
    ieee754.write(buf, value, offset, littleEndian, 52, 8)
    return offset + 8
  }

  Buffer.prototype.writeDoubleLE = function writeDoubleLE (value, offset, noAssert) {
    return writeDouble(this, value, offset, true, noAssert)
  }

  Buffer.prototype.writeDoubleBE = function writeDoubleBE (value, offset, noAssert) {
    return writeDouble(this, value, offset, false, noAssert)
  }

  // copy(targetBuffer, targetStart=0, sourceStart=0, sourceEnd=buffer.length)
  Buffer.prototype.copy = function copy (target, targetStart, start, end) {
    if (!Buffer.isBuffer(target)) throw new TypeError('argument should be a Buffer')
    if (!start) start = 0
    if (!end && end !== 0) end = this.length
    if (targetStart >= target.length) targetStart = target.length
    if (!targetStart) targetStart = 0
    if (end > 0 && end < start) end = start

    // Copy 0 bytes; we're done
    if (end === start) return 0
    if (target.length === 0 || this.length === 0) return 0

    // Fatal error conditions
    if (targetStart < 0) {
      throw new RangeError('targetStart out of bounds')
    }
    if (start < 0 || start >= this.length) throw new RangeError('Index out of range')
    if (end < 0) throw new RangeError('sourceEnd out of bounds')

    // Are we oob?
    if (end > this.length) end = this.length
    if (target.length - targetStart < end - start) {
      end = target.length - targetStart + start
    }

    var len = end - start

    if (this === target && typeof Uint8Array.prototype.copyWithin === 'function') {
      // Use built-in when available, missing from IE11
      this.copyWithin(targetStart, start, end)
    } else if (this === target && start < targetStart && targetStart < end) {
      // descending copy from end
      for (var i = len - 1; i >= 0; --i) {
        target[i + targetStart] = this[i + start]
      }
    } else {
      Uint8Array.prototype.set.call(
        target,
        this.subarray(start, end),
        targetStart
      )
    }

    return len
  }

  // Usage:
  //    buffer.fill(number[, offset[, end]])
  //    buffer.fill(buffer[, offset[, end]])
  //    buffer.fill(string[, offset[, end]][, encoding])
  Buffer.prototype.fill = function fill (val, start, end, encoding) {
    // Handle string cases:
    if (typeof val === 'string') {
      if (typeof start === 'string') {
        encoding = start
        start = 0
        end = this.length
      } else if (typeof end === 'string') {
        encoding = end
        end = this.length
      }
      if (encoding !== undefined && typeof encoding !== 'string') {
        throw new TypeError('encoding must be a string')
      }
      if (typeof encoding === 'string' && !Buffer.isEncoding(encoding)) {
        throw new TypeError('Unknown encoding: ' + encoding)
      }
      if (val.length === 1) {
        var code = val.charCodeAt(0)
        if ((encoding === 'utf8' && code < 128) ||
            encoding === 'latin1') {
          // Fast path: If `val` fits into a single byte, use that numeric value.
          val = code
        }
      }
    } else if (typeof val === 'number') {
      val = val & 255
    }

    // Invalid ranges are not set to a default, so can range check early.
    if (start < 0 || this.length < start || this.length < end) {
      throw new RangeError('Out of range index')
    }

    if (end <= start) {
      return this
    }

    start = start >>> 0
    end = end === undefined ? this.length : end >>> 0

    if (!val) val = 0

    var i
    if (typeof val === 'number') {
      for (i = start; i < end; ++i) {
        this[i] = val
      }
    } else {
      var bytes = Buffer.isBuffer(val)
        ? val
        : Buffer.from(val, encoding)
      var len = bytes.length
      if (len === 0) {
        throw new TypeError('The value "' + val +
          '" is invalid for argument "value"')
      }
      for (i = 0; i < end - start; ++i) {
        this[i + start] = bytes[i % len]
      }
    }

    return this
  }

  // HELPER FUNCTIONS
  // ================

  var INVALID_BASE64_RE = /[^+/0-9A-Za-z-_]/g

  function base64clean (str) {
    // Node takes equal signs as end of the Base64 encoding
    str = str.split('=')[0]
    // Node strips out invalid characters like \n and \t from the string, base64-js does not
    str = str.trim().replace(INVALID_BASE64_RE, '')
    // Node converts strings with length < 2 to ''
    if (str.length < 2) return ''
    // Node allows for non-padded base64 strings (missing trailing ===), base64-js does not
    while (str.length % 4 !== 0) {
      str = str + '='
    }
    return str
  }

  function toHex (n) {
    if (n < 16) return '0' + n.toString(16)
    return n.toString(16)
  }

  function utf8ToBytes (string, units) {
    units = units || Infinity
    var codePoint
    var length = string.length
    var leadSurrogate = null
    var bytes = []

    for (var i = 0; i < length; ++i) {
      codePoint = string.charCodeAt(i)

      // is surrogate component
      if (codePoint > 0xD7FF && codePoint < 0xE000) {
        // last char was a lead
        if (!leadSurrogate) {
          // no lead yet
          if (codePoint > 0xDBFF) {
            // unexpected trail
            if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
            continue
          } else if (i + 1 === length) {
            // unpaired lead
            if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
            continue
          }

          // valid lead
          leadSurrogate = codePoint

          continue
        }

        // 2 leads in a row
        if (codePoint < 0xDC00) {
          if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
          leadSurrogate = codePoint
          continue
        }

        // valid surrogate pair
        codePoint = (leadSurrogate - 0xD800 << 10 | codePoint - 0xDC00) + 0x10000
      } else if (leadSurrogate) {
        // valid bmp char, but last char was a lead
        if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
      }

      leadSurrogate = null

      // encode utf8
      if (codePoint < 0x80) {
        if ((units -= 1) < 0) break
        bytes.push(codePoint)
      } else if (codePoint < 0x800) {
        if ((units -= 2) < 0) break
        bytes.push(
          codePoint >> 0x6 | 0xC0,
          codePoint & 0x3F | 0x80
        )
      } else if (codePoint < 0x10000) {
        if ((units -= 3) < 0) break
        bytes.push(
          codePoint >> 0xC | 0xE0,
          codePoint >> 0x6 & 0x3F | 0x80,
          codePoint & 0x3F | 0x80
        )
      } else if (codePoint < 0x110000) {
        if ((units -= 4) < 0) break
        bytes.push(
          codePoint >> 0x12 | 0xF0,
          codePoint >> 0xC & 0x3F | 0x80,
          codePoint >> 0x6 & 0x3F | 0x80,
          codePoint & 0x3F | 0x80
        )
      } else {
        throw new Error('Invalid code point')
      }
    }

    return bytes
  }

  function asciiToBytes (str) {
    var byteArray = []
    for (var i = 0; i < str.length; ++i) {
      // Node's code seems to be doing this and not & 0x7F..
      byteArray.push(str.charCodeAt(i) & 0xFF)
    }
    return byteArray
  }

  function utf16leToBytes (str, units) {
    var c, hi, lo
    var byteArray = []
    for (var i = 0; i < str.length; ++i) {
      if ((units -= 2) < 0) break

      c = str.charCodeAt(i)
      hi = c >> 8
      lo = c % 256
      byteArray.push(lo)
      byteArray.push(hi)
    }

    return byteArray
  }

  function base64ToBytes (str) {
    return base64.toByteArray(base64clean(str))
  }

  function blitBuffer (src, dst, offset, length) {
    for (var i = 0; i < length; ++i) {
      if ((i + offset >= dst.length) || (i >= src.length)) break
      dst[i + offset] = src[i]
    }
    return i
  }

  // ArrayBuffer or Uint8Array objects from other contexts (i.e. iframes) do not pass
  // the `instanceof` check but they should be treated as of that type.
  // See: https://github.com/feross/buffer/issues/166
  function isInstance (obj, type) {
    return obj instanceof type ||
      (obj != null && obj.constructor != null && obj.constructor.name != null &&
        obj.constructor.name === type.name)
  }
  function numberIsNaN (obj) {
    // For IE11 support
    return obj !== obj // eslint-disable-line no-self-compare
  }

  }).call(this)}).call(this,require("buffer").Buffer)
  },{"base64-js":56,"buffer":57,"ieee754":58}],58:[function(require,module,exports){
  /*! ieee754. BSD-3-Clause License. Feross Aboukhadijeh <https://feross.org/opensource> */
  exports.read = function (buffer, offset, isLE, mLen, nBytes) {
    var e, m
    var eLen = (nBytes * 8) - mLen - 1
    var eMax = (1 << eLen) - 1
    var eBias = eMax >> 1
    var nBits = -7
    var i = isLE ? (nBytes - 1) : 0
    var d = isLE ? -1 : 1
    var s = buffer[offset + i]

    i += d

    e = s & ((1 << (-nBits)) - 1)
    s >>= (-nBits)
    nBits += eLen
    for (; nBits > 0; e = (e * 256) + buffer[offset + i], i += d, nBits -= 8) {}

    m = e & ((1 << (-nBits)) - 1)
    e >>= (-nBits)
    nBits += mLen
    for (; nBits > 0; m = (m * 256) + buffer[offset + i], i += d, nBits -= 8) {}

    if (e === 0) {
      e = 1 - eBias
    } else if (e === eMax) {
      return m ? NaN : ((s ? -1 : 1) * Infinity)
    } else {
      m = m + Math.pow(2, mLen)
      e = e - eBias
    }
    return (s ? -1 : 1) * m * Math.pow(2, e - mLen)
  }

  exports.write = function (buffer, value, offset, isLE, mLen, nBytes) {
    var e, m, c
    var eLen = (nBytes * 8) - mLen - 1
    var eMax = (1 << eLen) - 1
    var eBias = eMax >> 1
    var rt = (mLen === 23 ? Math.pow(2, -24) - Math.pow(2, -77) : 0)
    var i = isLE ? 0 : (nBytes - 1)
    var d = isLE ? 1 : -1
    var s = value < 0 || (value === 0 && 1 / value < 0) ? 1 : 0

    value = Math.abs(value)

    if (isNaN(value) || value === Infinity) {
      m = isNaN(value) ? 1 : 0
      e = eMax
    } else {
      e = Math.floor(Math.log(value) / Math.LN2)
      if (value * (c = Math.pow(2, -e)) < 1) {
        e--
        c *= 2
      }
      if (e + eBias >= 1) {
        value += rt / c
      } else {
        value += rt * Math.pow(2, 1 - eBias)
      }
      if (value * c >= 2) {
        e++
        c /= 2
      }

      if (e + eBias >= eMax) {
        m = 0
        e = eMax
      } else if (e + eBias >= 1) {
        m = ((value * c) - 1) * Math.pow(2, mLen)
        e = e + eBias
      } else {
        m = value * Math.pow(2, eBias - 1) * Math.pow(2, mLen)
        e = 0
      }
    }

    for (; mLen >= 8; buffer[offset + i] = m & 0xff, i += d, m /= 256, mLen -= 8) {}

    e = (e << mLen) | m
    eLen += mLen
    for (; eLen > 0; buffer[offset + i] = e & 0xff, i += d, e /= 256, eLen -= 8) {}

    buffer[offset + i - d] |= s * 128
  }

  },{}],59:[function(require,module,exports){
  // shim for using process in browser
  var process = module.exports = {};

  // cached from whatever global is present so that test runners that stub it
  // don't break things.  But we need to wrap it in a try catch in case it is
  // wrapped in strict mode code which doesn't define any globals.  It's inside a
  // function because try/catches deoptimize in certain engines.

  var cachedSetTimeout;
  var cachedClearTimeout;

  function defaultSetTimout() {
      throw new Error('setTimeout has not been defined');
  }
  function defaultClearTimeout () {
      throw new Error('clearTimeout has not been defined');
  }
  (function () {
      try {
          if (typeof setTimeout === 'function') {
              cachedSetTimeout = setTimeout;
          } else {
              cachedSetTimeout = defaultSetTimout;
          }
      } catch (e) {
          cachedSetTimeout = defaultSetTimout;
      }
      try {
          if (typeof clearTimeout === 'function') {
              cachedClearTimeout = clearTimeout;
          } else {
              cachedClearTimeout = defaultClearTimeout;
          }
      } catch (e) {
          cachedClearTimeout = defaultClearTimeout;
      }
  } ())
  function runTimeout(fun) {
      if (cachedSetTimeout === setTimeout) {
          //normal enviroments in sane situations
          return setTimeout(fun, 0);
      }
      // if setTimeout wasn't available but was latter defined
      if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
          cachedSetTimeout = setTimeout;
          return setTimeout(fun, 0);
      }
      try {
          // when when somebody has screwed with setTimeout but no I.E. maddness
          return cachedSetTimeout(fun, 0);
      } catch(e){
          try {
              // When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
              return cachedSetTimeout.call(null, fun, 0);
          } catch(e){
              // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
              return cachedSetTimeout.call(this, fun, 0);
          }
      }


  }
  function runClearTimeout(marker) {
      if (cachedClearTimeout === clearTimeout) {
          //normal enviroments in sane situations
          return clearTimeout(marker);
      }
      // if clearTimeout wasn't available but was latter defined
      if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
          cachedClearTimeout = clearTimeout;
          return clearTimeout(marker);
      }
      try {
          // when when somebody has screwed with setTimeout but no I.E. maddness
          return cachedClearTimeout(marker);
      } catch (e){
          try {
              // When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
              return cachedClearTimeout.call(null, marker);
          } catch (e){
              // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
              // Some versions of I.E. have different rules for clearTimeout vs setTimeout
              return cachedClearTimeout.call(this, marker);
          }
      }



  }
  var queue = [];
  var draining = false;
  var currentQueue;
  var queueIndex = -1;

  function cleanUpNextTick() {
      if (!draining || !currentQueue) {
          return;
      }
      draining = false;
      if (currentQueue.length) {
          queue = currentQueue.concat(queue);
      } else {
          queueIndex = -1;
      }
      if (queue.length) {
          drainQueue();
      }
  }

  function drainQueue() {
      if (draining) {
          return;
      }
      var timeout = runTimeout(cleanUpNextTick);
      draining = true;

      var len = queue.length;
      while(len) {
          currentQueue = queue;
          queue = [];
          while (++queueIndex < len) {
              if (currentQueue) {
                  currentQueue[queueIndex].run();
              }
          }
          queueIndex = -1;
          len = queue.length;
      }
      currentQueue = null;
      draining = false;
      runClearTimeout(timeout);
  }

  process.nextTick = function (fun) {
      var args = new Array(arguments.length - 1);
      if (arguments.length > 1) {
          for (var i = 1; i < arguments.length; i++) {
              args[i - 1] = arguments[i];
          }
      }
      queue.push(new Item(fun, args));
      if (queue.length === 1 && !draining) {
          runTimeout(drainQueue);
      }
  };

  // v8 likes predictible objects
  function Item(fun, array) {
      this.fun = fun;
      this.array = array;
  }
  Item.prototype.run = function () {
      this.fun.apply(null, this.array);
  };
  process.title = 'browser';
  process.browser = true;
  process.env = {};
  process.argv = [];
  process.version = ''; // empty string to avoid regexp issues
  process.versions = {};

  function noop() {}

  process.on = noop;
  process.addListener = noop;
  process.once = noop;
  process.off = noop;
  process.removeListener = noop;
  process.removeAllListeners = noop;
  process.emit = noop;
  process.prependListener = noop;
  process.prependOnceListener = noop;

  process.listeners = function (name) { return [] }

  process.binding = function (name) {
      throw new Error('process.binding is not supported');
  };

  process.cwd = function () { return '/' };
  process.chdir = function (dir) {
      throw new Error('process.chdir is not supported');
  };
  process.umask = function() { return 0; };

  },{}]},{},[1]);
