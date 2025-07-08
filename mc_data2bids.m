function mc_data2bids(subj)

% mc_data2bids

ispilot = false;
if ~isstruct(subj)
  if ~ischar(subj)
    subj = sprintf('sub-%03d', subj);
  end

  if startsWith(subj, 'pil')
    ispilot = true;
  end
  subj = mc_subjinfo(subj, [], 0);
end
bidsroot = '/project/3031008.01/bids';

bidssubj = fullfile(bidsroot, subj.subjname);
if exist(bidssubj, 'dir')
  fprintf('removing existing bidsfolder for subject %s\n', subj.subjname);
  system(sprintf('rm -rf %s', bidssubj));
end

dd = [];
dd.Name    = 'infant_faceshousesoddball'; % REQUIRED. Name of the dataset.
dd.Authors = {'Marlene Meyer', 'Jan Mathijs Schoffelen', 'Britta Westner', 'Robert Oostenveld'}; % OPTIONAL. List of individuals who contributed to the creation/curation of the dataset.
dd.Acknowledgements = {'Miranda Naaktgeboren', 'Norbert Hermesdorf'}; % OPTIONAL. Text acknowledging contributions of individuals or institutions beyond those listed in Authors or Funding.
%dd.HowToAcknowledge    = ft_getopt(dd, 'HowToAcknowledge'      ); % OPTIONAL. Instructions how researchers using this dataset should acknowledge the original authors. This field can also be used to define a publication that should be cited in publications that use the dataset.
%dd.Funding             = ft_getopt(dd, 'Funding'               ); % OPTIONAL. List of sources of funding (grant numbers)
%dd.EthicsApprovals     = ft_getopt(dd, 'EthicsApprovals'       ); % OPTIONAL. List of ethics committee approvals of the research protocols and/or protocol identifiers.
%dd.ReferencesAndLinks  = ft_getopt(dd, 'ReferencesAndLinks'    ); % OPTIONAL. List of references to publication that contain information on the dataset, or links.
%dd.DatasetDOI          = ft_getopt(dd, 'DatasetDOI'            ); % OPTIONAL. The Document Object Identifier of the dataset (not the corresponding paper).


% 1. copy over the *.fif data, rename, and create the initial version of the
% sidecar files.
docopy = true;
if docopy

  if ~iscell(subj.dataset)
    subj.dataset = {subj.dataset};
  end
  for k = 1:numel(subj.dataset)
    cfg          = [];
    cfg.bidsroot = bidsroot;
    cfg.dataset  = subj.dataset{k};
    cfg.suffix   = 'meg';
    cfg.ses      = 'opm01';
    if numel(subj.dataset)>1
      cfg.run      = num2str(k,'%02d');
    end
    if isfield(subj, 'event')
      % this writes a decoded version of the events into the tsv file
      cfg.events   = subj.event;
    end
    if ispilot
      cfg.sub = sprintf('pilot%s', subj.subjname(end-1:end));
    else
      cfg.sub      = subj.subjname(end-2:end);
    end
    cfg.task     = 'faceshousesoddball';
    cfg.method   = 'copy';

    % add some required stuff for the meg ds json
    cfg.meg.PowerLineFrequency  = 50;
    cfg.meg.DewarPosition       = 'n/a';
    cfg.meg.SoftwareFilters     = 'n/a';
    cfg.meg.DigitizedLandmarks  = false;
  	cfg.meg.DigitizedHeadPoints = false;

    hdr = ft_read_header(cfg.dataset, 'coilaccuracy', 0);

    % due to an issue with the Fieldline software (at least in the 0.9
    % version), the units of the trigger channel are represented incorrectly
    % in fif-file. This is overruled here
    hdr.chanunit{strcmp(hdr.label, 'di15')} = 'V';
    cfg.channels.name = hdr.label;
    cfg.channels.units = hdr.chanunit;
    
    cfg.dataset_description = dd;
    cfg.Manufacturer                = 'Fieldline'; % OPTIONAL. Manufacturer of the recording system ('CTF', 'Neuromag/Elekta', '4D/BTi', 'KIT/Yokogawa', 'ITAB', 'KRISS', 'Other')
    cfg.InstitutionName             = 'Donders Institute (DI)'; % OPTIONAL. The name of the institution in charge of the equipment that produced the composite instances.
    cfg.InstitutionalDepartmentName = 'DCCN/DCC'; % The department in the institution in charge of the equipment that produced the composite instances. Corresponds to DICOM Tag 0008, 1040 'Institutional Department Name'.

    data2bids(cfg);
  end

  for k = 1:numel(subj.dataset_er)
    cfg          = [];
    cfg.bidsroot = bidsroot;
    cfg.dataset  = subj.dataset_er{k};
    cfg.suffix   = 'meg';
    cfg.ses      = 'opm01';
    if numel(subj.dataset)>1
      cfg.run      = num2str(k,'%02d');
    end
    if isfield(subj, 'event')
      % this writes a decoded version of the events into the tsv file
      cfg.events   = subj.event;
    end
    if ispilot
      cfg.sub = sprintf('pilot%s', subj.subjname(end-1:end));
    else
      cfg.sub      = subj.subjname(end-2:end);
    end
    cfg.task     = 'emptyroom';
    cfg.method   = 'copy';

    % add some required stuff for the meg ds json
    cfg.meg.PowerLineFrequency  = 50;
    cfg.meg.DewarPosition       = 'n/a';
    cfg.meg.SoftwareFilters     = 'n/a';
    cfg.meg.DigitizedLandmarks  = false;
  	cfg.meg.DigitizedHeadPoints = false;

    hdr = ft_read_header(cfg.dataset, 'coilaccuracy', 0);

    % due to an issue with the Fieldline software (at least in the 0.9
    % version), the units of the trigger channel are represented incorrectly
    % in fif-file. This is overruled here
    hdr.chanunit{strcmp(hdr.label, 'di15')} = 'V';
    cfg.channels.name = hdr.label;
    cfg.channels.units = hdr.chanunit;
    
    cfg.dataset_description = dd;
    cfg.Manufacturer                = 'Fieldline'; % OPTIONAL. Manufacturer of the recording system ('CTF', 'Neuromag/Elekta', '4D/BTi', 'KIT/Yokogawa', 'ITAB', 'KRISS', 'Other')
    cfg.InstitutionName             = 'Donders Institute (DI)'; % OPTIONAL. The name of the institution in charge of the equipment that produced the composite instances.
    cfg.InstitutionalDepartmentName = 'DCCN/DCC'; % The department in the institution in charge of the equipment that produced the composite instances. Corresponds to DICOM Tag 0008, 1040 'Institutional Department Name'.

    data2bids(cfg);
  end

  % copy over the video datafile into the sourcedata folder
  if ~exist(fullfile(bidsroot, 'sourcedata'), 'dir')
    mkdir(fullfile(bidsroot, 'sourcedata'));
  end
  destinationdir = fullfile(bidsroot, 'sourcedata', sprintf('sub-%s', cfg.sub), 'video');
  if ~exist(fullfile(bidsroot, 'sourcedata', sprintf('sub-%s', cfg.sub), 'video'), 'dir')
    mkdir(destinationdir);
  end

  if isfield(subj, 'videofile') && ~isempty(subj.videofile)
    fname = sprintf('sub-%s_ses-%s_task-%s_video.mp4', cfg.sub, cfg.ses, cfg.task);
    copyfile(subj.videofile, fullfile(destinationdir, fname));
  end

  % copy over the video annotation data into the sourcedata folder
  if isfield(subj, 'annotfile') && ~isempty(subj.annotfile)
    fname = sprintf('sub-%s_ses-%s_task-%s_video-annot.txt', cfg.sub, cfg.ses, cfg.task);
    copyfile(subj.annotfile, fullfile(destinationdir, fname));
  end
end