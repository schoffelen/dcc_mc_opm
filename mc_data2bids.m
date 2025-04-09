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

% 1. copy over the *.fif data, rename, and create the initial version of the
% sidecar files.
docopy = true;
if docopy
  cfg          = [];
  cfg.bidsroot = bidsroot;
  cfg.dataset  = subj.dataset;
  cfg.suffix   = 'meg';
  cfg.ses      = 'opm01';
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

  cfg.dataset_description = [];
  cfg.dataset_description.Name    = ft_getopt(cfg.dataset_description, 'Name', 'infant_faceshousesoddball'); % REQUIRED. Name of the dataset.
  cfg.dataset_description.Authors = ft_getopt(cfg.dataset_description, 'Authors', {'Marlene Meyer', 'Jan Mathijs Schoffelen', 'Britta Westner', 'Robert Oostenveld'}); % OPTIONAL. List of individuals who contributed to the creation/curation of the dataset.
  cfg.dataset_description.Acknowledgements = ft_getopt(cfg.dataset_description, 'Acknowledgements', {'Miranda Naaktgeboren', 'Norbert Hermesdorf'}); % OPTIONAL. Text acknowledging contributions of individuals or institutions beyond those listed in Authors or Funding.
  %cfg.dataset_description.HowToAcknowledge    = ft_getopt(cfg.dataset_description, 'HowToAcknowledge'      ); % OPTIONAL. Instructions how researchers using this dataset should acknowledge the original authors. This field can also be used to define a publication that should be cited in publications that use the dataset.
  %cfg.dataset_description.Funding             = ft_getopt(cfg.dataset_description, 'Funding'               ); % OPTIONAL. List of sources of funding (grant numbers)
  %cfg.dataset_description.EthicsApprovals     = ft_getopt(cfg.dataset_description, 'EthicsApprovals'       ); % OPTIONAL. List of ethics committee approvals of the research protocols and/or protocol identifiers.
  %cfg.dataset_description.ReferencesAndLinks  = ft_getopt(cfg.dataset_description, 'ReferencesAndLinks'    ); % OPTIONAL. List of references to publication that contain information on the dataset, or links.
  %cfg.dataset_description.DatasetDOI          = ft_getopt(cfg.dataset_description, 'DatasetDOI'            ); % OPTIONAL. The Document Object Identifier of the dataset (not the corresponding paper).

  cfg.Manufacturer = ft_getopt(cfg, 'Manufacturer', 'Fieldline'); % OPTIONAL. Manufacturer of the recording system ('CTF', 'Neuromag/Elekta', '4D/BTi', 'KIT/Yokogawa', 'ITAB', 'KRISS', 'Other')
  %cfg.ManufacturersModelName            = ft_getopt(cfg, 'ManufacturersModelName'      ); % OPTIONAL. Manufacturer's designation of the model (e.g. 'CTF-275'). See 'Appendix VII' with preferred names
  %cfg.DeviceSerialNumber                = ft_getopt(cfg, 'DeviceSerialNumber'          ); % OPTIONAL. The serial number of the equipment that produced the composite instances. A pseudonym can also be used to prevent the equipment from being identifiable, as long as each pseudonym is unique within the dataset.
  %cfg.SoftwareVersions                  = ft_getopt(cfg, 'SoftwareVersions'            ); % OPTIONAL. Manufacturer's designation of the acquisition software.
  cfg.InstitutionName             = ft_getopt(cfg, 'InstitutionName', 'Donders Institute (DI)'); % OPTIONAL. The name of the institution in charge of the equipment that produced the composite instances.
  cfg.InstitutionalDepartmentName = ft_getopt(cfg, 'InstitutionalDepartmentName', 'DCCN/DCC'); % The department in the institution in charge of the equipment that produced the composite instances. Corresponds to DICOM Tag 0008, 1040 'Institutional Department Name'.


  data2bids(cfg);

  % copy over the video datafile into the sourcedata folder
  if ~exist(fullfile(bidsroot, 'sourcedata'), 'dir')
    mkdir(fullfile(bidsroot, 'sourcedata'));
  end
  if ~exist(fullfile(bidsroot, 'sourcedata', sprintf('sub-%s', cfg.sub), 'video'), 'dir')
    destinationdir = fullfile(bidsroot, 'sourcedata', sprintf('sub-%s', cfg.sub), 'video');
    mkdir(destinationdir);

    if isfield(subj, 'videofile')
      fname = sprintf('sub-%s_ses-%s_task-%s_video.mp4', cfg.sub, cfg.ses, cfg.task);

      copyfile(subj.videofile, fullfile(destinationdir, fname));
    end
  end

end